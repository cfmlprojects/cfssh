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


	function shell(required username , required password , required host , numeric port=22, required string userinput)  {
			var results = "";
			var System = classLoader.create("java.lang.System");
			var errStream = classLoader.create("java.io.ByteArrayOutputStream").init();
			var outStream = classLoader.create("java.io.ByteArrayOutputStream").init();
			var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
			var config = classLoader.create("java.util.Properties");
			config.put("StrictHostKeyChecking", "no");
			var jschSession = jsch.getSession(username, host, port);
			//arguments.userinput = arguments.userinput.replaceAll("\\\\r?\\\\n", "\\\\n");
			arguments.userinput = arguments.userinput.replaceAll("#chr(13)##chr(10)#", chr(10)).trim();
			var x = 0;
			jschSession.setConfig(config);
			
			// key authentication
			if(StructKeyExists(arguments, "key") && arguments.key != ""){
				jsch.addIdentity(arguments.key, password);
			} else {
				jschSession.setPassword(password);	
			}
			
			jschSession.connect();
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

			channel.disconnect();
			jschSession.disconnect();
			inStream.close();
			errStream.close();
			return results;
	}

	function exec(required username, required password, required host,numeric port=22, timeout=10000, required string userinput)  {

			var results = [];
			var System = classLoader.create("java.lang.System");
			var errStream = classLoader.create("java.io.ByteArrayOutputStream").init();
			var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
			var config = classLoader.create("java.util.Properties");
			config.put("StrictHostKeyChecking", "no");
			var jschSession=jsch.getSession(username, host, port);
			arguments.userinput = arguments.userinput.replaceAll("#chr(13)##chr(10)#", chr(10)).trim();
			jschSession.setConfig(config);
			
			// key authentication
			if(StructKeyExists(arguments, "key") && arguments.key != ""){
				jsch.addIdentity(arguments.key, password);
			} else {
				jschSession.setPassword(password);	
			}
			
			//addDebugMessage("Connecting to #host# as #username#...");
			jschSession.connect();
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
			jschSession.disconnect();
			inStream.close();
			errStream.close();
			if(beenRunin >= timeout) {
				throw(type="sshd.exec.error",message="request timed out!");
			}
			if(exitstatus != 0) {
				throw(type="sshd.exec.error",message="Error! Exit code:#exitstatus# message: #commandresult# (#command#)");
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

	Query function listDir(required username, required password, required host,numeric port=22, required string directory=".")  {
		var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
		var config = classLoader.create("java.util.Properties");
		config.put("StrictHostKeyChecking", "no");
		var jschSession=jsch.getSession(username, host, port);
		jschSession.setConfig(config);
		// key authentication
		if(StructKeyExists(arguments, "key") && arguments.key != ""){
			jsch.addIdentity(arguments.key, password);
		} else {
			jschSession.setPassword(password);	
		}
		jschSession.connect();
        var channel = jschSession.openChannel("sftp");
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
        	var reged = preg_match("([drwx-]+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\S+\s\d+\s[\d|\:]+)\s+(\S+)",file.getLongname());
        	querySetCell(entries,"name",file.getFilename(),row);
        	querySetCell(entries,"path",remotedir & "/" & file.getFilename(),row);
        	querySetCell(entries,"url",file.getFilename(),row);
        	querySetCell(entries,"length",attrs.getSize(),row);
        	querySetCell(entries,"hardlinks",reged[3],row);
        	querySetCell(entries,"owner",reged[4],row);
        	querySetCell(entries,"group",reged[5],row);
        	querySetCell(entries,"accessed",attrs.getATimeString(),row);
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
		channel.disconnect();
        sleep(500); // give it a half second to realize we're exiting
		jschSession.disconnect();
		return entries;
    }


	function putFile(required localFile, required username, required password, required host, numeric port=22, remoteDirectory="", filename="")  {
		var System = classLoader.create("java.lang.System");
        var localFile = classLoader.create("java.io.File").init(localFile);
        if(filename == "") {
        	filename = localFile.getName();
        }
		var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
		var jschSession = jsch.getSession(username, host, port);
		var config = classLoader.create("java.util.Properties");

		var ChannelSftp = classLoader.create("com.jcraft.jsch.ChannelSftp");
		var mode = ChannelSftp.OVERWRITE;
		
		// key authentication
		if(StructKeyExists(arguments, "key") && arguments.key != ""){
			jsch.addIdentity(arguments.key, password);
		} else {
			jschSession.setPassword(password);	
		}
		
		config.put("StrictHostKeyChecking", "no");
		jschSession.setConfig(config);
		
		jschSession.connect();

        channel = jschSession.openChannel("sftp");
        channel.connect();

        if(arguments.remoteDirectory != "") {
	        channel.cd(arguments.remoteDirectory);
        }

        channel.put(classLoader.create("java.io.FileInputStream").init(localFile), filename, mode);
        channel.quit();
        var exitstatus = channel.getExitStatus();
        channel.disconnect();
        sleep(500); // give it a half second to realize we're exiting
		jschSession.disconnect();
		return exitstatus;
    }

	function getFile(required remoteFile, required localFile, required username, required password, required host,numeric port=22, remoteDirectory="")  {
        var localFile = classLoader.create("java.io.FileOutputStream").init(localFile);
		var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
		var config = classLoader.create("java.util.Properties");
		config.put("StrictHostKeyChecking", "no");
		var jschSession=jsch.getSession(username, host, port);
		jschSession.setConfig(config);
		
		// key authentication
		if(StructKeyExists(arguments, "key") && arguments.key != ""){
			jsch.addIdentity(arguments.key, password);
		} else {
			jschSession.setPassword(password);	
		}
		
		jschSession.connect();
        channel = jschSession.openChannel("sftp");
        channel.connect();
        if(remoteDirectory != "") {
	        channel.cd(remoteDirectory);
        }
        channel.get(remoteFile,localFile);
        var exitstatus = channel.getExitStatus();
        channel.exit();
        channel.disconnect();
        sleep(500); // give it a half second to realize we're exiting
		jschSession.disconnect();
		return exitstatus;
    }


}