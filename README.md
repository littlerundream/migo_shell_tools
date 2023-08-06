# Migo Shell Tools

## Project Overview

* Product Name: MigoShellTools
* Project code: migoshelltools
* Official address: http://migo.top/

This is a collection of shell scripting tools designed to improve the efficiency of your daily office routine.

## Functions
- SSH tools -- This is a GUI tool that assists users in logging into servers that have been added ssh-free.
- K8s tools -- This is a set of graphical helper scripts for Kubernetes that automate the generation and execution of common `kubectl` commands.
- PV/UV statistics -- Analyze the number of hits on your site using the nginx access log.
- CVS tools -- A collection of tools for CVS commits, conflict handling and file comparisons.


## Requirements

- Bash 5.x


## Development environment deployment/installation

The project code is developed in Bash and can be used on any operating system that has a Bash execution environment, such as Linux distributions, Mac OSX, or Windows with WSL installed.

### Foundation Installation

#### 1. Cloning source code

Clone `migo_shell_tools` source code locally:

    > git clone https://github.com/littlerundream/migo_shell_tools.git

#### 2. Run the specified version of the script

1). Find the directory of the script to be executed：

```shell
cd auth_ssh_tools
```

2).  Install required dependencies, for example, the ssh login helper, which requires support for the dialog graphical tool.

```bash
yum install dialog
```
> For the libraries that each tool depends on, please refer to the tool's own ReadMe documentation.

3). Executable script

```bash
 bash ./ssh_login_helper.bash
```

## Expansion pack utilization

| Dependencies |  Required version | One Sentence Description | Corresponding Scripts 
| --- | --- | --- | --- 
| dialog |  1.3 | display dialog boxes from shell scripts | ssh_tools/ssh_login_helper.bash

