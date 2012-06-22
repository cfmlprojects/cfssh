<cffile action="read" file="#getCurrentTemplatePath()#" variable="code">
<cfoutput><pre>
Code:
#replace(code,"<","&lt;","all")#</pre></cfoutput>