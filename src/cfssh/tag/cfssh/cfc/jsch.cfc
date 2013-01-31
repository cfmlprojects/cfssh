component {
	function init() {
   		classLoader = new LibraryLoader(getDirectoryFromPath(getMetaData(this).path) & "lib/").init();
/*
	    if(verbose) {
	        JSch.setLogger(new com.jcraft.jsch.Logger(){
	            public boolean isEnabled(int level){
	                return true;
	            }
	            public void log(int level, String message){
	                base.log(message, Project.MSG_INFO);
	            }
	        });
	    }
*/
		return this;
	}

	function getSession(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="") {
		var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
		var config = classLoader.create("java.util.Properties");
		config.put("StrictHostKeyChecking", "no");
		if (key != "") {
			if(passphrase != "") {
				jsch.addIdentity(key,passphrase);
			} else {
				jsch.addIdentity(key);
			}
		}
		var jschSession=jsch.getSession(username, host, port);
		jschSession.setConfig(config);
		if(password != "") {
			jschSession.setPassword(password);
		}
		jschSession.connect(val(timeout*100));
        if(fingerprint != "") {
	        var hostkey = jschSession.getHostKey();
	        if(ucase(fingerprint) != ucase(hostkey.getFingerPrint(jsch))) {
	        	jschSession.disconnect();
				throw(type="ssh.auth.error",
					message="fingerprints did not match! [#fingerprint# != #hostkey.getFingerPrint(jsch)#]");
	        }
        }
        return jschSession;
	}


	function shell(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="", required string userinput)  {
			var results = "";
			var System = classLoader.create("java.lang.System");
			var errStream = classLoader.create("java.io.ByteArrayOutputStream").init();
			var outStream = classLoader.create("java.io.ByteArrayOutputStream").init();
			var jschSession = getSession(argumentCollection = arguments);
			var err = "";
			try {
				//arguments.userinput = arguments.userinput.replaceAll("\\\\r?\\\\n", "\\\\n");
				arguments.userinput = arguments.userinput.replaceAll("#chr(13)##chr(10)#", chr(10)).trim();
				var x = 0;
				var command = classLoader.create("java.io.ByteArrayInputStream").init(arguments.userinput.getBytes("UTF-8"));
				var channel=jschSession.openChannel("shell");
				channel.setInputStream(command);
				channel.setOutputStream(outStream);
				channel.setExtOutputStream(errStream);
				var inStream=channel.getInputStream();
				channel.connect();
				var byteClass = classLoader.create( "java.lang.Byte");
				byteClass.Init(1);
				var tmp = classLoader.create("java.lang.reflect.Array").newInstance(byteClass.TYPE, 1024);

				while(true){
				  while(inStream.available()>0){
				    i=inStream.read(tmp, 0, 1024);
				    if(i<0)break;
				    str = classLoader.create("java.lang.String").init(tmp,0,i);
				    results = results & str;
				    //System.out.print(str);
				  }
				  if(channel.isClosed()){
				   // System.out.println("exit-status: "+channel.getExitStatus());
				    break;
				  }
				}
			}
			catch (any ex) {
				err = ex;
			}
			finally {
				try {
					channel.disconnect();
				} catch (any e) {}
				try {
					jschSession.disconnect();
				} catch (any e) {}
				try {
					inStream.close();
					errStream.close();
				} catch (any e) {}
			}
			if(isStruct(err)) {
				throw(err);
			}
			return results;
	}

	function exec(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="", required string userinput)  {

			var results = [];
			var System = classLoader.create("java.lang.System");
			var errStream = classLoader.create("java.io.ByteArrayOutputStream").init();
			arguments.userinput = arguments.userinput.replaceAll("#chr(13)##chr(10)#", chr(10)).trim();
			var jschSession = getSession(argumentCollection = arguments);
/*
			var c = jschSession.openChannel("exec");
			var oss = c.getOutputStream();
			var iss = c.getInputStream();
			c.setCommand("scp .");
			c.connect();
			request.debug(iss.read());
			c.disconnect();
			throw ("");
*/
			var err = "";
			try {
				var x = 0;
			    for(x=1; x lte listLen(userinput,chr(10)); x ++) {
			    	var exitstatus = 0;
					var channel=jschSession.openChannel("exec");
					var command=listGetAt(arguments.userinput,x,chr(10));
					//System.out.println("command:" & command);
					//addDebugMessage("Running command:" & command);
					// X Forwarding
					// channel.setXForwarding(true);
					//channel.setInputStream(System.in);
					//channel.setInputStream(javaCast("null",""));
					var outStream = channel.getOutputStream();
					//channel.setExtOutputStream(errStream);
					var inStream=channel.getInputStream();
					//System.out.println("connecting...");
					channel.setCommand(command);
					channel.connect();
	        		//system.out.println(readLine(inStream));
					var byteClass = classLoader.create("java.lang.Byte");
					byteClass.Init(1);
					var tmp = classLoader.create("java.lang.reflect.Array").newInstance(byteClass.TYPE, 1024);
					//System.out.println("waiting...");
					var tickBegin = GetTickCount();
					var beenRunin = 0;
					var commandresult = classLoader.create("java.io.ByteArrayOutputStream").init();
					while (beenRunin < timeout) {
						tickend = GetTickCount();
						beenRunin = (tickEnd - tickBegin);
						while (inStream.available() > 0) {
							i = inStream.read(tmp, 0, 1024);
							if (i < 0) break;
							str = classLoader.create("java.lang.String").init(tmp, 0, i);
							commandresult.write(tmp);
						}
						if (channel.isClosed()) {
							exitstatus = channel.getExitStatus();
							break;
						}
					}
					//System.out.println("disconnecting!");
					channel.disconnect();
			    }
			    commandresult = commandresult.toString().trim();
			}
			catch (any ex) {
				err = ex;
			}
			finally {
				try {
					channel.disconnect();
				} catch (any e) {}
				try {
					jschSession.disconnect();
				} catch (any e) {}
				try {
					inStream.close();
					errStream.close();
				} catch (any e) {}
			}
			if(isStruct(err)) {
				throw(err);
			}
			if(beenRunin >= timeout) {
				throw(type="ssh.exec.error",message="request timed out!");
			}
			if(exitstatus != 0) {
				throw(type="ssh.exec.error",message="Error! Exit code:#exitstatus# message: #commandresult# (#command#)");
			}
		    arrayAppend(results,commandresult);
			return results;
	}

    private String function readLine(instream) {
		var ByteArrayOutputStream = classLoader.create("java.io.ByteArrayOutputStream");
        var baos = ByteArrayOutputStream.init();
        for (;;) {
            var c = instream.read();
            if (c == '\n') {
                return baos.toString();
            } else if (c == -1) {
                throw("End of stream");
            } else {
                baos.write(c);
            }
        }
    }


	function preg_match(regex,str) {
	    var results = arraynew(1);
	    var match = "";
	    var x = 1;
	    if (REFind(regex, str, 1)) {
	        match = REFind(regex, str, 1, TRUE);
	        for (x = 1; x lte arrayLen(match.pos); x = x + 1) {
	            if(match.len[x])
	                results[x] = mid(str, match.pos[x], match.len[x]);
	            else
	                results[x] = '';
	        }
	    }
	    return results;
	}

	Query function listDir(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="", required string directory=".")  {
		var jschSession = getSession(argumentCollection = arguments);
        var channel = jschSession.openChannel("sftp");
		var err = "";
		try {
	        channel.connect();
	        var remotedir = channel.pwd();
	        var files = channel.ls(directory);
	        var entries = queryNew("name,path,url,length,longname,hardlinks,accessed,lastModified,attributes,flags,extended,isdirectory,isLink,mode,owner,uid,group,gid");
	        queryAddRow(entries,files.size());
	        files = files.iterator();
	        var row = 0;
	        while(files.hasNext()) {
	        	row++;
	        	var file = files.next();
	        	var attrs = file.getAttrs();
	        	//var reged = preg_match("([drwx-]+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\S+\s\d+\s[\d|\:]+)\s+(\S+)",file.getLongname());
	        	var reged = preg_match("([drwxt-]+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\d+).*",file.getLongname());
	        	querySetCell(entries,"name",file.getFilename(),row);
	        	querySetCell(entries,"path",remotedir & "/" & file.getFilename(),row);
	        	querySetCell(entries,"url",file.getFilename(),row);
	        	querySetCell(entries,"length",attrs.getSize(),row);
	        	querySetCell(entries,"hardlinks",reged[3],row);
	        	querySetCell(entries,"owner",reged[4],row);
	        	querySetCell(entries,"group",reged[5],row);
	        	querySetCell(entries,"accessed",convertUnixTimestamp(attrs.getATime()),row);
	        	querySetCell(entries,"lastModified",attrs.getMTimeString(),row);
	        	querySetCell(entries,"longname",file.getLongname(),row);
	        	querySetCell(entries,"mode",right(FormatBaseN(attrs.getPermissions(),8),3),row);
	        	querySetCell(entries,"flags",attrs.getFlags(),row);
	        	querySetCell(entries,"uid",attrs.getUId(),row);
	        	querySetCell(entries,"gid",attrs.getGId(),row);
	        	querySetCell(entries,"extended",!isNull(attrs.getExtended())?attrs.getExtended().toString():"",row);
	        	querySetCell(entries,"isdirectory",attrs.isDir(),row);
	        	querySetCell(entries,"isLink",attrs.isLink(),row);
	        	querySetCell(entries,"attributes",attrs.getPermissionsString(),row);
	        }
		}
		catch (any ex) {
			err = ex;
		}
		finally {
			try {
				channel.disconnect();
        		sleep(500); // give it a half second to realize we're exiting
			} catch (any e) {}
			try {
				jschSession.disconnect();
			} catch (any e) {}
		}
		if(isStruct(err)) {
			throw(err);
		}
		return entries;
    }


	function putFile(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="", required localFile, remoteDirectory="", filename="")  {
		var System = classLoader.create("java.lang.System");
        var localFile = classLoader.create("java.io.File").init(localFile);
        if(filename == "") {
        	filename = localFile.getName();
        }
		var ChannelSftp = classLoader.create("com.jcraft.jsch.ChannelSftp");
		var mode = ChannelSftp.OVERWRITE;
		var jschSession = getSession(argumentCollection = arguments);
		var err = "";
		try {
	        channel = jschSession.openChannel("sftp");
	        channel.connect();
	        if(remoteDirectory != "") {
		        channel.cd(remoteDirectory);
	        }
	        channel.put(classLoader.create("java.io.FileInputStream").init(localFile), filename, mode);
	        channel.quit();
	        var exitstatus = channel.getExitStatus();
		}
		catch (any ex) {
			err = ex;
		}
		finally {
			try {
				channel.disconnect();
        		sleep(500); // give it a half second to realize we're exiting
			} catch (any e) {}
			try {
				jschSession.disconnect();
			} catch (any e) {}
		}
		if(isStruct(err)) {
			throw(err);
		}
		return exitstatus;
    }

	function getFile(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="", required remoteFile, required localFile, remoteDirectory="")  {
        var localFile = classLoader.create("java.io.FileOutputStream").init(localFile);
		var jschSession = getSession(argumentCollection = arguments);
		var err = "";
		try {
	        channel = jschSession.openChannel("sftp");
	        channel.connect();
	        if(remoteDirectory != "") {
		        channel.cd(remoteDirectory);
	        }
	        channel.get(remoteFile,localFile);
	        var exitstatus = channel.getExitStatus();
	        channel.exit();
		}
		catch (any ex) {
			err = ex;
		}
		finally {
			try {
				channel.disconnect();
        		sleep(500); // give it a half second to realize we're exiting
			} catch (any e) {}
			try {
				jschSession.disconnect();
			} catch (any e) {}
		}
		if(isStruct(err)) {
			throw(err);
		}
		return exitstatus;
    }

	function delete(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="", required item)  {
		var jschSession = getSession(argumentCollection = arguments);
		var err = "";
		try {
	        channel = jschSession.openChannel("sftp");
	        channel.connect();
	        channel.rm(item);
	        var exitstatus = channel.getExitStatus();
	        channel.exit();
		}
		catch (any ex) {
			err = ex;
		}
		finally {
			try {
				channel.disconnect();
        		sleep(500); // give it a half second to realize we're exiting
			} catch (any e) {}
			try {
				jschSession.disconnect();
			} catch (any e) {}
		}
		if(isStruct(err)) {
			throw(err);
		}
		return exitstatus;
    }

	function exists(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="", required item)  {
		var jschSession = getSession(argumentCollection = arguments);
		var err = "";
		var exitstatus = "";
		var files = [];
		try {
	        channel = jschSession.openChannel("sftp");
	        channel.connect();
	        var remotedir = channel.pwd();
	        files = channel.ls(item);
	        exitstatus = (channel.getExitStatus() == -1) ? true : false;
	        channel.exit();
		}
		catch (Any ex) {
			if(ex.message == item) {
				exitstatus = false;
			} else {
				err = ex;
			}
		}
		finally {
			try {
				channel.disconnect();
        		sleep(500); // give it a half second to realize we're exiting
			} catch (any e) {}
			try {
				jschSession.disconnect();
			} catch (any e) {}
		}
		if(isStruct(err)) {
			throw(err);
		}
		return exitstatus;
    }

	function remove(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="", required item)  {
		delete(argumentCollection=arguments);
	}

	function removeDir(required username, password="", key="", passphrase="", required host, numeric port=22, numeric timeout=30, fingerprint="", required item)  {
		delete(argumentCollection=arguments);
	}

	function convertUnixTimestamp(input) {
		return lsDateTimeFormat(
			DateConvert("utc2Local", Replace(Replace(DateAdd("s", input, "January 1 1970 00:00:00"), "{ts '", ""), "'}", ""))
			,"EEE MMM d HH:mm:ss z yyyy"
			);
	}

}