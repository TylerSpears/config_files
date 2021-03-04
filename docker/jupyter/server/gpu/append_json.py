#!/usr/env python
import json

with open("jupyter_config.json", "r") as f:
    config = json.read(f)

config["CondaKernelSpecManager"] = {"kernelspec_path": "--user"}

with open("jupyter_config.json", "w") as f:
    json.dump(config, f)
