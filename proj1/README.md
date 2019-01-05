# COP5615-DOS-projects
This is a repository of the assignments for course COP5615 / Distributed Operating Systems Principles.

## Proj1

<b>Actor modeling</b>: In this project you have to use exclusively the actor facility
in Elixir (projects that do not use multiple actors or use any other form
of parallelism will receive no credit). A model similar to the one indicated
in class for the problem of adding up a lot of numbers can be used here, in
particular define worker actors that are given a range of problems to solve and
a boss that keeps track of all the problems and perform the job assignment.

<b>Input</b>: The input provided (as command line to your program, e.g. my app)
will be two numbers: N and k. The overall goal of your program is to find all
k consecutive numbers starting at 1 and up to N, such that the sum of squares
is itself a perfect square (square of an integer).  

<b>Output</b>: Print, on independent lines, the first number in the sequence for each
solution.
Exam

```bash
cd proj1
time mix run proj1.exs 10000000 24 --no-mix-exs
```

## Proj1 bonus problem
Use remote actors and run you program on 2+ machines. Use your solution to
solve a really large instance.  

### Setup
I have used multiple dockers to simulate different machines on the same network. I have used docker names and its ip address to configure the elixir nodes. The steps for doing so are mentioned below

1. Run the dockers. The docker image is the official elixir image on docker hub.
   The below command will start a docker with bash.

   docker run --name <docker_name> -it --rm elixir bash
   e.g.: docker run --name mc_d_1 -it --rm elixir bash
   
   Similarly, I started 4 more dockers in different terminals
   docker run --name mc_d_2 -it --rm elixir bash
   docker run --name mc_d_3 -it --rm elixir bash
   docker run --name mc_d_4 -it --rm elixir bash
   docker run --name mc_d_5 -it --rm elixir bash
   
2. Get the ip of the docker by running the below command inside each docker.
   awk 'END{print $1}' /etc/hosts

3. Set up the elixir node with a name and cookie. The cookie content can be anything but needs to be same for all nodes which needs to be connected.
   iex --name <docker_name>@<docker_ip_address> --cookie <some shared cookie string>
   e.g.:
   ```bash
   iex --name mc_d_1@172.17.0.2 --cookie somecookie
   ```

   Similarly, for other dockers. The ip address should be copied from the output for step 2 for each docker.
   ```bash
   iex --name mc_d_2@172.17.0.3 --cookie somecookie   
   iex --name mc_d_3@172.17.0.4 --cookie somecookie   
   iex --name mc_d_4@172.17.0.5 --cookie somecookie   
   iex --name mc_d_5@172.17.0.6 --cookie somecookie  
   ```

4. Copy the code to all the docker terminals. It can also be done by passing the file as a command line argument -S script_file_path if the docker has access to the files.
   Copy and paste the contents of proj1_multi_machine.exs in directory proj1_bonus in each elixir node in the dockers. This makes sure the required functions are present in each machine when called from the master machine.

5. Start the master node.  
time mix run proj1_master_machine.exs n k node_name somecookie --no-mix-exs  
e.g.:
    ```bash
    time mix run proj1_master_machine.exs 10000 24 master@duttasourav-home somecookie --no-mix-exs
    ```