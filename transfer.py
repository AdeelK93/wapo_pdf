#!/usr/bin/python3.7
from rmapy.document import ZipDocument
from rmapy.api import Client
from os import listdir

rmapy = Client()
# This registers the client as a new device. The received device token is
# stored in the users directory in the file ~/.rmapi, the same as with the
# go rmapi client.
# rmapy.register_device("ayvnpfoc")
# It's always a good idea to refresh the user token every time you start
# a new session.
rmapy.renew_token()
# Should return True

# delete the old one
collection = rmapy.get_meta_items()
oldWapo = [ d for d in collection if d.VissibleName == 'The Washington Post']
if len(oldWapo)>0:
  rmapy.delete(oldWapo[0])

# rawDocument = ZipDocument(doc="wapo.pdf")
# rawDocument.metadata["VissibleName"]="The Washington Post"
uuid=listdir("ZipDocument")[0].split('.')[0]
rawDocument = ZipDocument(uuid, file="wapo.zip")
rawDocument.metadata["VissibleName"]="The Washington Post"

rmapy.upload(rawDocument)