/// 
Class Workflow.BP.DiabetesPlanManager Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='EnsLib.Workflow.TaskResponse' height='2000' width='2000' >
<context>
<property name='action' type='%String' instantiate='0' >
<parameters>
<parameter name='MAXLEN'  value='50' />
</parameters>
</property>
</context>
<sequence xend='200' yend='550' >
<call name='Create task' target='Task_OUT' async='1' xpos='200' ypos='250' >
<request type='EnsLib.Workflow.TaskRequest' >
<assign property="callrequest.%Actions" value="&quot;Save,Delete&quot;" action="set" />
<assign property="callrequest.%Subject" value="&quot;Task created by HL7&quot;" action="set" />
<assign property="callrequest.%Message" value="&quot;This is a task generated after receive a HL7&quot;" action="set" />
<assign property="callrequest.%UserName" value="&quot;patient&quot;" action="set" />
</request>
<response type='EnsLib.Workflow.TaskResponse' >
<assign property="context.action" value="callresponse.%Action" action="set" />
</response>
</call>
<sync calls='Create task' type='all' xpos='200' ypos='350' />
<trace name='A trace' value='"Task created"' xpos='200' ypos='450' />
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
