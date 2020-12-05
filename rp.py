import os
import re
import mysql.connector

mydb = mysql.connector.connect(host="5.196.39.48", user="kossolax", password="7Hst478TKX%^7f^R", database="rp_csgo")
mycur = mydb.cursor()
rootdir = "C:\\Users\\kossolax\\Documents\\riplay-rp"

lines = []
for root, folders, files in os.walk(rootdir):
    for i in files:
        if (".sp" in i or ".inc" in i) and "_not_used" not in root:
            with open(os.path.join(root, i), 'r', encoding='utf8') as f:
                for j in f.readlines():
                    j = j.replace("\t", "").replace("\\", "/").strip()

                    if ".mdl" in j or ".vvd" in j or ".phy" in j or ".dx90.vtx" in j:
                        lines.append(j)
                    if ".pcf" in j:
                        lines.append(j)
                    if ".vtf" in j or ".vmt" in j:
                        lines.append(j)

files = []
for i in lines:
    m1 = re.search('((?:"| )\S+\/\S+\.\S{3}")', i)
    m2 = re.search('((?:"| )\S+\/\S+%\S+\.\S{3}")', i)

    if m1 and not m2:
        i = m1.group(1).strip()
        m3 = re.search('\"(\S+\S+)\"', i)
        if m3:
            files.append(m3.group(1).strip())

db = []
for i in files:
    ext = i.split(".")[-1]
    path = None
    if ext == "mdl" or ext == "phy" or ext == "vvd" or ext == "vtx":
        path = "models/"
    elif ext == "vtf" or ext == "vmt":
        path = "materials/"
    elif ext == "wav" or ext == "mp3":
        path = "sound/"
    elif ext == "pcf":
        path = "particles/"

    if path is not None:
        if i.startswith(path) is False:
            i = path + i
        db.append(i)
        if ext == "mdl":
            db.append(i.replace(".mdl", ".phy"))
            db.append(i.replace(".mdl", ".vvd"))
            db.append(i.replace(".mdl", ".dx90.vtx"))

mycur.execute("SELECT `path` FROM `rp_download`")
for i in mycur.fetchall():
    db.append(i[0].replace("\\", "/").strip())

try:
    try:
        os.rmdir("files")
    except:
        pass
    os.mkdir("files")
except:
    pass
db = list(set(db))
db.sort()
for i in db:
    print("wget -x http://fastdl.riplay.fr/csgo/"+ i)