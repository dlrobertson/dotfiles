import os

def chdir(debugger, args, result, dict):
    dir = args.strip()
    if dir:
        path = os.path.expanduser(args)
        os.chdir(path)
    else:
        os.chdir(os.path.expanduser("~"))
    print "Current working directory: {}".format(os.getcwd())
