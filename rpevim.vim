if !has('python')
	echo "Error: Required vim compiled with +python"
	finish
endif

function! GetSftp(remote_hostname, remote_user, remote_file, remote_pass, to_url)
	python << EOF

import base64, getpass, os, socket, sys, traceback, paramiko, vim

remote_hostname = vim.eval("a:remote_hostname")
remote_user = vim.eval("a:remote_user")
remote_file = vim.eval("a:remote_file")
remote_pass = vim.eval("a:remote_pass")
to_url = vim.eval("a:to_url")

paramiko.util.log_to_file("/tmp/paramiko.log")

username, hostname = remote_user, remote_hostname

port = 22
#if hostname.find(':') >= 0:
#	hostname, portstr = hostname.split(':')
#	port = int(portstr)

hostkeytype = None
hostkey = None

try:
	host_keys = paramiko.util.load_host_keys(os.path.expanduser('~/.ssh/known_hosts'))
except IOError:
	try:
		# try ~/ssh/ too, because windows can't have a folder named ~/.ssh/
		host_keys = paramiko.util.load_host_keys(os.path.expanduser('~/ssh/known_hosts'))
	except IOError:
		print '*** Unable to open host keys file'
		host_keys = {}

if host_keys.has_key(hostname):
	hostkeytype = host_keys[hostname].keys()[0]
	hostkey = host_keys[hostname][hostkeytype]

	print 'using host key of type %s' % hostkeytype

try:
	#print hostname, port
	#print username, password, hostkey
	
	t = paramiko.Transport((hostname, port))
	t.connect(username=username, password=password, hostkey=hostkey)
	sftp = paramiko.SFTPClient.from_transport(t)

	dirlist = sftp.listdir('.')

	sftp.get(remote_file, to_url)
	t.close()
except Exception, e:
	print '*** Caught exception: %s: %s' % (e.__class__, e)
	traceback.print_exc()
EOF
endfunction


"function! GetSftp(remote_hostname, remote_user, remote_file, remote_pass, to_url)
command! -nargs=0 GetSftp call GetSftp("localhost", "johnny", "teste", "corduroy", "/tmp/teste")
