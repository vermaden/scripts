#! /usr/bin/env python3

from sys                   import argv,exit
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers    import FTPHandler
from pyftpdlib.servers     import FTPServer
import os

if len(argv) != 2:
  print("usage:", os.path.basename(argv[0]), "PORT")
  print()
  exit(1)

authorizer = DummyAuthorizer()
authorizer.add_user("user", "password", ".", perm="elradfmw")
authorizer.add_anonymous(".")
handler = FTPHandler
handler.authorizer = authorizer
handler.passive_ports = range(60000, 64001)
address = ("0.0.0.0", argv[1])
ftpd = FTPServer(address, handler)
ftpd.serve_forever()

