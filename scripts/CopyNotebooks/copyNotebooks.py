__author__ = 'Suraj Bang'
from optparse import OptionParser
from io import *
import urllib2
import json
import pandas as pd
import os
from pandas.io.json import json_normalize
import datetime,math 
from poster.encode import multipart_encode
from poster.streaminghttp import register_openers


class fileHandle:
    def __init__(self,filename):
        self.filename = filename
    def openFile(self):
        if os.path.exists(self.filename):
            self.file = open(self.filename, 'a',encoding="utf-8")
        else:
            self.file = open(self.filename, 'w',encoding="utf-8")
    def writeFile(self,msg):
        self.file.write(unicode(msg))
    def closeFile(self):
        self.file.close()

# Perform rest call 
def apiCall ( env, token, operation, payload=None,method=None):
    data = {'env': env, 'operation': operation}
    url = 'https://%(env)s.qubole.com/api/latest/%(operation)s' % data
    if operation != 'account/':
        log('\nCall URL - ' + url)
    if payload != None:
       log('\npayload - ' + str(payload))
    if operation != 'notebooks/import':   
        headers = {"X-AUTH-TOKEN" : token, "Content-Type" : "application/json" , "Accept" : "application/json"}
        if payload == None:
            request = urllib2.Request(url=url,headers=headers) 
        else:
            request = urllib2.Request(url=url,headers=headers,data=json.dumps(payload)) 
        if method != None:
            request.get_method = lambda: '%s' % method       
    else:
        register_openers()
        datagen, headers = multipart_encode(payload)
        request = urllib2.Request(url, datagen, headers)
        request.add_header('X-AUTH-TOKEN', token )
        request.add_header('Accept', 'application/json')

    response = urllib2.urlopen(request)
    rjson = response.read()
    if rjson == None or rjson == "":
       rjson = '{}'
    return json.loads(rjson)
        

# Unravel the complex folder hirearchies - returns list of complete directory path that should exist or created in target
# remove dups and sort so parent directory is created before child
def getFoldersToCreate(folders,folderType):
    log('\n'+folderType)
    folderList = []
    for folder in folders:
        if folder.find(seperator) == -1:
            folderList.append(folder)
        else:
            foldersplit = folder.split(seperator)
            for i in range(len(foldersplit)):
                folderList.append(seperator.join(foldersplit[0:i+1]))
    folderList = list(set(folderList))
    folderList.sort(key=len)
    folderList.remove(folderType)    
    if folderType == 'Users':
        folderListLoop = list(folderList)
        for folder in folderListLoop:
            if folder.count(seperator) == 1:
                folderList.remove(folder) 
    return folderList 


# create folders in target 
def createFolders(folderList):
    for folder in folderList:
        idx = folder.rfind(seperator)
        log('\n\nCreating folder "' + folder[idx+1:] + '" under parent location "' + folder[0:idx] + '"')
        payload = {"name": folder[idx+1:] , "location": folder[0:idx] , "type" :"notes"}
        rjson = apiCall(env=opts.tgtEnv, token=opts.tgtToken,operation='folders/',payload=payload)
        if rjson['success']:
            log('\nFolder Creation success')
        elif rjson['message'] =='Folder is already created':
            log('\nFolder already exists')     
        else:
            log('\nError creating folder - ' + rjson['message'])
            exit(1)
        

# get info for all notebooks
def getNotebooks(folderType,envType):
    if envType =='target':
        rjson = apiCall(env=opts.tgtEnv,token=opts.tgtToken,operation='notebooks/search.json?location=%s'%folderType) 
    else:
        rjson = apiCall(env=opts.srcEnv,token=opts.srcToken,operation='notebooks/search.json?location=%s'%folderType)     
    if folderType=='Users':
        nb = json_normalize(rjson,'notes').sort_values(by=['location','name'])
    else:
        nb = json_normalize(rjson,'notes').sort_values(by=['name'])
    return nb


# export notebook locally 
def exportNotebooks(nbname,notebookid,filename):
    log('\n\nExporting Notebook ID - ' + str(notebookid))
    log('\nNotebook Name - ' + nbname)
    rjson = apiCall(env=opts.srcEnv,token=opts.srcToken,operation='notebooks/%s/export'%notebookid) 
    if 'error_message' in rjson:
        log('\n'+rjson)
        log('\nExport failed')
        exit(1)
    else:
        log('\nExport Completed')
        log('\nWriting file to local disk')
        file = open(filename, "w")
        file.write(json.dumps(rjson,ensure_ascii=False))
        file.close()
        log('\nfilename - ' + filename)

            

# Update notebook tags
def updateNotebooktags(env,notebookid,tags):
    log('\nUpdating notebook tags')
    payload = {"tag_keywords": tags }
    rjson = apiCall(env=opts.tgtEnv,token=opts.tgtToken,operation='notebooks/%s/tags'%notebookid,payload=payload) 
    if 'error_message' in rjson:
        log('\n'+rjson)
        log('\nNotebook tags NOT updated')
        exit(1)
    else:
        log('\nNotebook tags updated')
    

# log successful copied notebook info to csv
def updateCopiedNotebooks(folderType,name,old_notebook_id,new_notebook_id):
    copyNBSuccessFile.writeFile("%s,%s,%s,%s\n"%(folderType,name,old_notebook_id,new_notebook_id))


def log(msg):
    logFile.writeFile(msg)    

# import a notebook
def importNotebooks(notebookid,filename,name,location,note_type,tgtClusterID,folderType):
    log('\nImporting Notebook')
    if tgtClusterID == None:
        payload = {"name": name , "location": location , "note_type": note_type , "file":  open(filename,'rb')  , "nbaddmode": "import-from-computer" }
    else:    
        payload = {"name": name , "location": location , "note_type": note_type , "file":  open(filename,'rb') ,"cluster_id" : tgtClusterID , "nbaddmode": "import-from-computer" }
    rjson = apiCall(env=opts.tgtEnv,token=opts.tgtToken,operation='notebooks/import',payload=payload) 
    if rjson['success']:
        log('\nImport Successful')
        newnotebookid = rjson['id']
        log('\nNew notebookid - %s' % newnotebookid)
        updateCopiedNotebooks(folderType,name,notebookid,newnotebookid)  
        return newnotebookid
    else:
        log('\nError importing notebook - %s' % rjson['message'])
        return None
   

# get cluster labels to map notebooks to new cluster id
def getClusterLabels(env,token,envType):
    log('\n\nGet %s cluster labels' %envType)
    rjson = apiCall(env=env,token=token,operation='clusters/')
    nb = json_normalize(rjson)
    if envType == 'target':
        labeldict = dict(zip( nb['cluster.label'].apply(lambda x: '|'.join(x)) , nb['cluster.id'])) 
    else:
        labeldict = dict(zip( nb['cluster.id'], nb['cluster.label'].apply(lambda x: '|'.join(x)) ))        
    log('\nCluster Labels - ')
    log(labeldict)
    return labeldict
         

# get notebooks that have been already copied 
def getAlreadyImporteNotebooks(folderType):
    if copyNBSuccessFileExists:
        nbAlready = pd.read_csv(copyNBSuccessFileName)
        for index, row in nbAlready.iterrows():
            if row['notetype'] == folderType:
                log('\nNotebook "%s" having id - %s already imported. Skipping it.' % (row['name'],row['old_notebook_id']))
        return nbAlready.old_notebook_id.tolist()
    else:
        return []


# get account info 
def getAccountInfo(env,token,envType):
    rjson = apiCall(env=env,token=token,operation='account/') 
    acc = json_normalize(rjson)
    return acc

# get account users
def getUsers(env,token,envType):
    log('\n\nGet %s user info' % envType)
    rjson = apiCall(env=env,token=token,operation='accounts/get_users/') 
    usrs = json_normalize(rjson,'users')
    if envType == 'target':
        userdict = dict(zip( usrs['email'] , usrs['id'])) 
    else:
        userdict = dict(zip( usrs['id'], usrs['email'] ))
    log(userdict)  
    return userdict


#delete target notebook
def deleteTargetNoteBook(tgtNBID):
    log('\nDeleteing Target Notebook - %s' % str(tgtNBID))
    rjson = apiCall(env=opts.tgtEnv,token=opts.tgtToken,operation='notebooks/%s'%tgtNBID,method='DELETE') 
    if 'error_message' in rjson:
        log('\n'+rjson)
        log('\nFailed to delete Target Notebook')
    else:
        log('\nTarget Notebook deleted')


def checkDuplicateNotebookNames(nb):
    #nbDup = pd.concat(g for _, g in nb.groupby("name") if len(g) > 1)    
    nbname = nb["name"]
    nbDup=nb[nbname.isin(nbname[nbname.duplicated()])]
    if len(nbDup.index) > 0:
        log('\n\nImport contains notebooks with same names')
        log('\nNoteBook_ID,Name,User')
        log('\n---------------------')
        for index, row in nbDup.iterrows():
            log('\n'+str(row['id'])+','+row['name']+','+ str(srcUsers.get(row['qbol_user_id'])))
        log('\nPlease rename notebooks to have them unique across all users. Exiting the import process.\n')
        exit(-1)

# main logic
def copyNotebooks(folderType):
    usedClusterIDList = []
    log('\n\n--- Starting Copying of %s Notebooks ---' % folderType)
    log('\n\nGet %s Notebooks' %folderType)
    nb = getNotebooks(folderType,'source')

    summaryList.append('\n\n****** Summary for %s Notebooks ******' % folderType) 
    summaryList.append('\nTotal Notebooks - %s' % str(len(nb.index)))

    if repAllNB == 'Y':
        tgtnb = getNotebooks(folderType,'target')
        tgtnbdict = dict(zip( tgtnb['name'] , tgtnb['id']))     

    #Filter notebooks that do not have a target user
    srcUserIDsMissingList = []
    if folderType =='Users':
        log('\n\nCheck if users exists in target')
        srcUserIDs = nb.qbol_user_id.unique().tolist()
        for srcUserID in srcUserIDs:
            tgtQblUserID = None 
            srcEmailID = srcUsers.get(srcUserID)  
            tgtQblUserID = tgtUsers.get(srcEmailID)  
            if tgtQblUserID == None:
                srcUserIDsMissingList.append(srcUserID)
                log('\nSkipping notebooks for user ' + srcEmailID + ' - user does not exits in target account.')
    if len(srcUserIDsMissingList) > 0:
        summaryList.append('\nNotebooks Skipped due to user not in target account - %s' % str(len(nb[nb.qbol_user_id.isin(srcUserIDsMissingList)].index)))
        nb = nb[~nb.qbol_user_id.isin(srcUserIDsMissingList)]

    
    # check if notebooks with same name exists
    if folderType =='Users':
        checkDuplicateNotebookNames(nb)

    log('\n\nSkip Already Imported Notebooks')
    nbAlreadyList = getAlreadyImporteNotebooks(folderType)
    nbFil = nb[~nb.id.isin(nbAlreadyList)]
    if len(nbAlreadyList) > 0:
        summaryList.append('\nNotebooks Skipped as already imported - %s' % str(len(nb[nb.id.isin(nbAlreadyList)].index)))
    

    if len(nbFil.index) > 0:

        #create folders
        folders = nbFil.location.unique().tolist()
        log('\n\nSrc Notebook folders -')
        log(folders)
        folderList = getFoldersToCreate(folders,folderType)
        if len(folderList) > 0:
            log('\n\nTarget Notebook folders to create -')
            log(folderList)
            createFolders(folderList)

        file = 'notebook_%s.json'
        log('\n\n--- Starting Export Import Process for %s Notebooks ---' % folderType)
        nbfilesizecnt = 0
        nbsuccesscnt = 0
        nbfailcnt = 0
        for index, row in nbFil.iterrows():
            nbname = row['name']
            notebookid = row['id']
            location = row['location']
            tgtQblUserID = None 
            filename = file % (notebookid) 
            exportNotebooks(nbname,notebookid,filename) 
            if isFileSizeOK(filename):
                if repAllNB == 'Y':
                    tgtNBID = None
                    tgtNBID = tgtnbdict.get(row['name'])
                    if tgtNBID != None:
                        deleteTargetNoteBook(tgtNBID)
                if math.isnan(row['cluster_id']):
                    srcClusterID = None
                else:
                    srcClusterID = row['cluster_id']   
                srcClusterLabel = srcClusterLabels.get(srcClusterID) 
                tgtClusterID = tgtClusterLabels.get(srcClusterLabel)  
                if srcClusterLabel == None:
                    log('\nNo cluster attached to notebook')
                elif tgtClusterID == None:
                    log('\nNo target cluster found with matching label %s' % srcClusterLabel)
                else:
                    log('\nFound target cluster with matching label')   
                newnotebookid = importNotebooks(notebookid,filename,nbname,row['location'],row['note_type'],tgtClusterID,folderType)
                if newnotebookid != None:
                    nbsuccesscnt = nbsuccesscnt + 1
                    if len(row['tags']) > 0:
                        updateNotebooktags(opts.tgtEnv,newnotebookid,row['tags'])
                    if srcClusterID != None:
                        usedClusterIDList.append(int(srcClusterID))
                else:
                    nbfailcnt = nbfailcnt + 1
            else:
                nbfilesizecnt = nbfilesizecnt + 1                
            log('\nremoving local file')
            os.remove(filename)           
        log('\n\n--- Export Import Process of %s Notebooks Completed ---' % folderType)
        summaryList.append('\nNotebooks Skipped due to file size limitation of 25mb - %s' % str(nbfilesizecnt))
        summaryList.append('\nNotebooks copy failed - %s' % str(nbfailcnt))
        summaryList.append('\nNotebooks copy succeded - %s' % str(nbsuccesscnt))   
    else:
        log('\n\n--- No %s Notebooks to export and import ---' % folderType)            
    return list(set(usedClusterIDList))            


def printIntpLocationPaths():
    envStrDict = { 'api' : 's3' , 'us' :'s3'  }
    log('\n\n*** Interpreter files, if needed can be manually copied between the clusters to retain previous settings ***')
    log('\nSource Interpreter Location ---> Target Interpreter Location')
    srcfiletype = envStrDict.get(opts.srcEnv)
    tgtfiletype = envStrDict.get(opts.tgtEnv)
    srcStgLoc = srcAcc['storage_location'][0]
    tgtStgLoc = tgtAcc['storage_location'][0]
    for srcClusterID in usedClusterIDList:
        srcClusterLabel = srcClusterLabels.get(srcClusterID) 
        tgtClusterID = tgtClusterLabels.get(srcClusterLabel)  
        if tgtClusterID == None:
            log('\n%s://%s/%s/spark/conf/interpreter.json --> No target cluster id'  % (srcfiletype,srcStgLoc,srcClusterID))
        else:
            log('\n%s://%s/%s/spark/conf/interpreter.json --> %s://%s/%s/spark/conf/interpreter.json'  % (srcfiletype,srcStgLoc,srcClusterID,tgtfiletype,tgtStgLoc,tgtClusterID))


def checkArguments():
    envs = ['api','us']
    ynOptions = ['y','n','Y','N']
    optparser = OptionParser()
    optparser.add_option("-s", "--srcToken", dest="srcToken", default="", help="Mandatory - provide your Qubole API source account token")
    optparser.add_option("-t", "--tgtToken", dest="tgtToken", default="", help="Mandatory - provide your Qubole API target account token")
    optparser.add_option("-i", "--srcEnv", dest="srcEnv" , default="api", choices=envs , help="Optional - provide the Qubole source enviornment, default value is api")
    optparser.add_option("-o", "--tgtEnv", dest="tgtEnv" , default="api", choices=envs, help="Optional - provide the Qubole target enviornment, default value is api")
    optparser.add_option("-r", "--replaceAllNB", dest="repAllNB" , default="N", help="Optional - drop the target notebook if it exists, default value is N")
    (opts, args) = optparser.parse_args()
    if (opts.srcToken == None or opts.srcToken == ''  or opts.tgtToken == None or opts.tgtToken == '' ):
        optparser.print_help()
        exit(1)
    else:
        return (opts,args)    


def isFileSizeOK(filename):
    # size in MBs
    quboleSizeLimit = 25.0
    fileSize = os.path.getsize(filename) / 1024 / 1024.0
    if fileSize > quboleSizeLimit:
        log('\nFile size is %sMB is greater than Qubole file size limit %sMB' % (str(float("{0:.2f}".format(fileSize))),str(quboleSizeLimit)))
        log('\nSkipping import for the Notebook due to file size limit')
        return False
    else:
        return True



#### Start main ###
summaryList = []
usedClusterIDList = []
seperator = '/'
now = datetime.datetime.now()
nowStr = now.strftime("%Y%m%d%H%M%S")
(opts, args) = checkArguments()

repAllNB = opts.repAllNB.upper()
# Generate log file name using src and tgt account id
srcAcc = getAccountInfo(opts.srcEnv,opts.srcToken,'source')
tgtAcc = getAccountInfo(opts.tgtEnv,opts.tgtToken,'target')
preFileName = opts.srcEnv + '_' + str(srcAcc['id'][0]) +'_to_' + opts.tgtEnv  + '_'+ str(tgtAcc['id'][0]) + '_'
copyNBSuccessFileName = preFileName + 'NBCopySuccess'  + '.csv'
logFileName =  preFileName + nowStr + '.log'
logFile = fileHandle(logFileName)
logFile.openFile()

log('--- Execution Started ---')
log('\nStarting Execution Time - %s' % str(now))
log('\n\nSrc Enviornment - %s' %opts.srcEnv)
log('\nSrc Account Name - %s' % srcAcc['name'][0])
log('\nSrc Account ID - %s' % srcAcc['id'][0])
log('\n\nTgt Enviornment - %s' %opts.tgtEnv)
log('\nTgt Account Name - %s' % tgtAcc['name'][0])
log('\nTgt Account ID - %s' % tgtAcc['id'][0])
log('\n\nCopied Notebooks CSV - %s' % copyNBSuccessFileName)



# get cluster labels and users for source and target
srcClusterLabels = getClusterLabels(opts.srcEnv,opts.srcToken,'source')
tgtClusterLabels = getClusterLabels(opts.tgtEnv,opts.tgtToken,'target')
srcUsers = getUsers(opts.srcEnv,opts.srcToken,'source')
tgtUsers = getUsers(opts.tgtEnv,opts.tgtToken,'target')


if os.path.exists(copyNBSuccessFileName) and repAllNB == 'Y':
    log('\n\n Deleting the existing csv file')
    os.remove(copyNBSuccessFileName)     

# Track copied notebooks in a csv file , on rerun already copied notebooks will be skipped
copyNBSuccessFile = fileHandle(copyNBSuccessFileName)
copyNBSuccessFileExists = False
if os.path.exists(copyNBSuccessFileName):
    copyNBSuccessFile.openFile()
    copyNBSuccessFileExists = True
else:
    copyNBSuccessFile.openFile()
    copyNBSuccessFile.writeFile(u"notetype,name,old_notebook_id,new_notebook_id\n")


#Copy User Notebooks
clusterIDs = copyNotebooks('Users')
usedClusterIDList.extend(clusterIDs)


#Copy Common Notebooks
clusterIDs = copyNotebooks('Common')
usedClusterIDList.extend(clusterIDs)


usedClusterIDList = list(set(usedClusterIDList))
if len(usedClusterIDList) > 0:
    printIntpLocationPaths()


for line in summaryList:
    log(line)


copyNBSuccessFile.closeFile()    
now = datetime.datetime.now()
log('\n\nEnding Execution Time - %s' % str(now))
log('\n--- Execution Completed ---')
logFile.closeFile()
