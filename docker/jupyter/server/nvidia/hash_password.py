#!/usr/bin/env python
import notebook.auth
from getpass import getpass

plain_pass = str(getpass("Please input a password and press ENTER\n"))
if len(plain_pass) == 0:
    ValueError("ERROR: Cannot give empty password")

hashed_password = notebook.auth.passwd(plain_pass)
with open('hashed_passwd.txt', 'w') as f:
    f.write(hashed_password)

