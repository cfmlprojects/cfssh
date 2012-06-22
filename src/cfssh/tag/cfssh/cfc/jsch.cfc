component {
	/**
	 * http://remark.overzealous.com/manual/usage.html
	 **/
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
			var errStream = classLoader.create("java.io.ByteArrayOutputStream").init();
			var outStream = classLoader.create("java.io.ByteArrayOutputStream").init();
			var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
			var config = classLoader.create("java.util.Properties");
			config.put("StrictHostKeyChecking", "no");
			var jschSession = jsch.getSession(username, host, 22);
			//arguments.userinput = arguments.userinput.replaceAll("\\\\r?\\\\n", "\\\\n");
			arguments.userinput = arguments.userinput.replaceAll("\\\\s*\\\\r?\\\\n\\\\s*", "\\\\n").trim();
			var x = 0;
			if(listLen(userinput,"\\n") gt 0){
			    for(x=1; x lte listLen(userinput,"\\n"); x ++) {
			    	results = exec(username,password,host,port,listGetAt(userinput,x,"\\n"));
			    }
			    return results;
			}
			jschSession.setConfig(config);
			jschSession.setPassword(password);
			jschSession.connect();
			var command = classLoader.create("java.io.ByteArrayInputStream").init(arguments.userinput.getBytes("UTF-8"));
			var channel=jschSession.openChannel("shell");
			channel.setInputStream(command);

			channel.setOutputStream(outStream);

			//FileOutputStream fos=new FileOutputStream("/tmp/stderr");
			//((ChannelExec)channel).setErrStream(fos);
			channel.setErrStream(errStream);

			var in=channel.getInputStream();

			channel.connect();

			var thread = classLoader.create("java.lang.Thread");
			var byteClass = classLoader.create( "java.lang.Byte");
			byteClass.Init(1);
			var tmp = classLoader.create("java.lang.reflect.Array").newInstance(byteClass.TYPE, 1024);

			while(true){
			  while(in.available()>0){
			    i=in.read(tmp, 0, 1024);
			    if(i<0)break;
			    str = classLoader.create("java.lang.String").init(tmp,0,i);
			    results = results & str;
			    //System.out.print(new String(tmp, 0, i));
			  }
			  if(channel.isClosed()){
			   // System.out.println("exit-status: "+channel.getExitStatus());
			    break;
			  }
			  try{Thread.sleep(1000);}
			  catch(Exception ee){}
			}

			channel.disconnect();
			jschSession.disconnect();
			in.close();
			return results & errStream.toString();
	}

	function exec(required username, required password, required host,numeric port=22, required string userinput)  {
			var results = [];
			var errStream = classLoader.create("java.io.ByteArrayOutputStream").init();
			var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
			var config = classLoader.create("java.util.Properties");
			config.put("StrictHostKeyChecking", "no");
			var jschSession=jsch.getSession(username, host, port);
			//arguments.userinput = arguments.userinput.replaceAll("\\\\r?\\\\n", "\\\\n");
			arguments.userinput = arguments.userinput.replaceAll("\\s*\\r?\\n\\s*", "\\n").trim();
			jschSession.setConfig(config);
			jschSession.setPassword(password);
			//addDebugMessage("Connecting to #host# as #username#...");
			jschSession.connect();
			var x = 0;
		    for(x=1; x lte listLen(userinput,chr(13)&chr(10)); x ++) {
				var channel=jschSession.openChannel("exec");
				var command=listGetAt(arguments.userinput,x,chr(13)&chr(10));
				channel.setCommand(command);
				//addDebugMessage("Running command:" & command);
				// X Forwarding
				// channel.setXForwarding(true);

				//channel.setInputStream(System.in);
				channel.setInputStream(javaCast("null",""));

				//channel.setOutputStream(outStream);

				//FileOutputStream fos=new FileOutputStream("/tmp/stderr");
				//((ChannelExec)channel).setErrStream(fos);
				channel.setErrStream(errStream);

				var in=channel.getInputStream();

				channel.connect();

				var thread = classLoader.create("java.lang.Thread");
				var byteClass = classLoader.create( "java.lang.Byte");
				byteClass.Init(1);
				var tmp = classLoader.create("java.lang.reflect.Array").newInstance(byteClass.TYPE, 1024);

				while(true){
				  while(in.available()>0){
				    i=in.read(tmp, 0, 1024);
				    if(i<0)break;
				    str = classLoader.create("java.lang.String").init(tmp,0,i);
				    arrayAppend(results, str & errStream.toString());
				    //System.out.print(new String(tmp, 0, i));
				  }
				  if(channel.isClosed()){
				   // System.out.println("exit-status: "+channel.getExitStatus());
				    break;
				  }
				  thread.sleep(1000);
				}

				channel.disconnect();
		    }
			jschSession.disconnect();
			in.close();
			return results;
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
		jschSession.setPassword(password);
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
		jschSession.disconnect();
		return entries;
    }

	function putFile(required localFile, required username, required password, required host,numeric port=22, remoteDirectory="")  {
        var localFile = classLoader.create("java.io.File").init(localFile);
        var filename = localFile.getName();
		var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
		var config = classLoader.create("java.util.Properties");
		config.put("StrictHostKeyChecking", "no");
		var jschSession=jsch.getSession(username, host, port);
		jschSession.setConfig(config);
		jschSession.setPassword(password);
		jschSession.connect();
        channel = jschSession.openChannel("sftp");
        channel.connect();
        if(remoteDirectory != "") {
	        channel.cd(remoteDirectory);
        }
        channel.put(classLoader.create("java.io.FileInputStream").init(localFile), filename);
        channel.disconnect();
		jschSession.disconnect();
		return true;
    }

	function getFile(required remoteFile, required localFile, required username, required password, required host,numeric port=22, remoteDirectory="")  {
        var localFile = classLoader.create("java.io.FileOutputStream").init(localFile);
		var jsch = classLoader.create("com.jcraft.jsch.JSch").init();
		var config = classLoader.create("java.util.Properties");
		config.put("StrictHostKeyChecking", "no");
		var jschSession=jsch.getSession(username, host, port);
		jschSession.setConfig(config);
		jschSession.setPassword(password);
		jschSession.connect();
        channel = jschSession.openChannel("sftp");
        channel.connect();
        if(remoteDirectory != "") {
	        channel.cd(remoteDirectory);
        }
        channel.get(remoteFile,localFile);
        channel.disconnect();
		jschSession.disconnect();
		return true;
    }


}