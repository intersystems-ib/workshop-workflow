# Workflow Workshop
This project is an example of configuration and use of InterSystems IRIS Workflow functionality simulating the treatment of patients with high blood pressure.

What will you find in this project?

## Worflow UI
Angular application to use as a front-end.

## IRIS
InterSystems IRIS instance configured by default to create and run an interoperability production configured to work with Workflow engine.

# What do you need to make it run?

## Running Docker Containers:

Open a terminal in Visual Studio and just write:
```
docker-compose up -d
```

You will see 2 containers running on your Docker.

![Docker Desktop](/images/docker_running.png)

Now it's time to configure IRIS.

## InterSystems IRIS configuration

Docker deployment will configure automatically the production wich manages the admission of HL7 messages and the creation of tasks, you don't need to do anything.

![Production](/images/production.png)

HL7_File_IN is configured to read HL7 files from **/shared/in** folder and resend the HL7 messages to **Workflow.BP.BloodPressurePlan** where they will be processed.

![HL7 folders](/images/in_folder.png)

**Workflow.BP.BloodPressurePlan**
This Business Process cover the entire functionality for the patient, it creates the user associated to the National Document of Identity and manages the tasks depending the values fetched from the HL7 messages.

![BPL](/images/bpl.png)

**AutomaticBloodPressureRole** and **ManualBloodPressureRole** Business Operations will connect our Business Process with the Workflow engine, creating and returning the generated tasks.

# Opening Angular application.

This project is configured to deploy an Angular application in the following address: [URL](http://localhost:4200). This application has been created with Angular Material to simulate an application for smartphones, if you are using Google Chrome or Firefox you can change the visualization pressing **CTRL + SHIFT + M**

To log in Workflow UI application you can use the FakeDoctor account created during the Docker deployment, the username is **FakeDoctor** and the password is **SYS**

![Login screen](/images/login_workflow.png)

# Testing workflows

To launch the process you only have to copy and paste **message_1_1.hl7** into **/shared/in** folder. With this action a new user will be created (**07751332X/SYS**) and two new tasks will be associated to him.

![Tasks](/images/tasks_list.png)

One of this tasks will be automatic and the system will close it as soon as a new hl7 file (**message_1_1.hl7**)