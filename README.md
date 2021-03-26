# BIG-IP TGW Examples

There are two examples in this repo.

1. Using Transit Gateway Connect
2. Using a BIG-IP to create a Firewall Sandwich in TGW

# TGW Connect

To run a demo of TGW Connect you will first need to run terraform in the `terraform` directory.

Next you will run the terraform code in the `connect` directory.  Note that this requires the AWS CLI and to be run on a Linux host.

***Warning*** This demo is not complete.

# FW Sandwich

This is an example of using a BIG-IP to create a FW sandwich in an inspection VPC.

In this example a BIG-IP is load balancing multiple FW devices in an A/A deployment.  The FW devices are configured to transparently inspect traffic.  The BIG-IP is configured to preserve the source and destination IP addresses as it passes through the inspection VPC.

This solution may be helpful in situations where you are unable to use a Gateway Load Balancer (lack of GENEVE support of network device).  This does not require any overlay networking.  The one requirement is that the FW devices are configured with a static route to the BIG-IP devices.

This is based on the following blog post: https://aws.amazon.com/blogs/architecture/field-notes-working-with-route-tables-in-aws-transit-gateway/

You can also get details of a FW Sandwich from: https://www.f5.com/services/resources/white-papers/load-balancing-101-firewall-sandwiches

## Topology

There are 3 VPCs in this environment:

- Client: 10.0.0.0/16
- Inspection: 10.1.0.0/16
- Workload: 10.2.0.0/16

Transit Gateway is configured to send traffic from the Client VPC through the Inspection VPC transparently.

## Deploying

To deploy this repo start in the `terraform` directory.

```
terraform init
terraform apply
```

You will see an output of the deployed devices.

```
Outputs:

BigIp = 192.0.2.4
Client = 192.0.2.5
Firewall-1 = 10.1.3.240
Firewall-2 = 10.1.3.182
Inspection = 192.0.2.10
Workload = 192.0.2.20
```

Using SSH forwarding you can connect to the "Inspection" instance to access the Firewall instances (username ubuntu).

After you run the `terraform` directory do the same in the `vpc` directory.  You should see an output of TMSH commands to run on the BIG-IP device.

```
Tmsh =   # run the following TMSH commands on the BIG-IP device
create /net self external-float address 10.1.3.86/24 traffic-group traffic-group-1 allow-service none vlan external
create /ltm pool tgw_pool members replace-all-with { 10.1.7.1:0 }
create /ltm poo fw_pool members replace-all-with { 10.1.3.240:0 10.1.3.182:0 }
create /ltm virtual to_fw_vs destination 10.0.0.0:0 ip-protocol any pool fw_pool translate-address disabled translate-port disabled mask 255.0.0.0  profiles replace-all-with  { fastL4 } vlans replace-all-with { internal } vlans-enabled
create /ltm virtual to_tgw_vs destination 10.0.0.0:0 ip-protocol any pool tgw_pool translate-address disabled translate-port disabled mask 255.0.0.0  profiles replace-all-with  { fastL4 } vlans replace-all-with { external } vlans-enabled
```

You will also want to verify that the "bigip1" device is the "active" device.  This is currently not fully setup for HA (see Further Work below).
## Demo

Login via the Public IP to the "Client" host.  From there run the command:

```
ubuntu@ip-10-0-0-4:~$ curl 10.2.3.4/txt
================================================
 ___ ___   ___                    _
| __| __| |   \ ___ _ __  ___    /_\  _ __ _ __
| _||__ \ | |) / -_) '  \/ _ \  / _ \| '_ \ '_ \
|_| |___/ |___/\___|_|_|_\___/ /_/ \_\ .__/ .__/
                                      |_|  |_|
================================================

      Node Name: F5 Internal 1
     Short Name: ip-10-2-3-4

      Server IP: 10.2.3.4
    Server Port: 80

      Client IP: 10.0.0.4
    Client Port: 59444

Client Protocol: HTTP
 Request Method: GET
    Request URI: /txt

    host_header: 10.2.3.4
     user-agent: curl/7.58.0
```

From one of the FW hosts you should be able to run TCPDUMP and observe the traffic.

```
ubuntu@ip-10-1-3-182:~$ sudo tcpdump -i any -s 0  -nnn -vvv -e port 80
tcpdump: listening on any, link-type LINUX_SLL (Linux cooked), capture size 262144 bytes
...
05:53:10.230417  In 12:0d:19:16:3f:7f ethertype IPv4 (0x0800), length 144: (tos 0x0, ttl 62, id 44312, offset 0, flags [DF], proto TCP (6), len$
th 128)
    10.0.0.4.59454 > 10.2.3.4.80: Flags [P.], cksum 0x006d (correct), seq 1:77, ack 1, win 491, options [nop,nop,TS val 1226369961 ecr 96296058$
], length 76: HTTP, length: 76
        HEAD /txt HTTP/1.1
        Host: 10.2.3.4
        User-Agent: curl/7.58.0
        Accept: */*
...
05:53:10.231827  In 12:0d:19:16:3f:7f ethertype IPv4 (0x0800), length 196: (tos 0x0, ttl 62, id 1173, offset 0, flags [DF], proto TCP (6), lengt
h 180)
    10.2.3.4.80 > 10.0.0.4.59454: Flags [P.], cksum 0x09cf (correct), seq 1:129, ack 77, win 489, options [nop,nop,TS val 962960592 ecr 12263699
61], length 128: HTTP, length: 128
        HTTP/1.1 200 OK
        Server: nginx/1.17.1
        Date: Mon, 15 Feb 2021 05:53:10 GMT
        Content-Type: text/plain
        Connection: keep-alive
```

## How it works

In this environment TGW is configured to send traffic from the Client VPC to the Inspection VPC subnet of 10.1.5.0/24.

This subnet is configured to forward traffic to the internal interface of the BIG-IP that is on 10.1.7.0/24.

The BIG-IP forwards traffic to the FW devices that are attached on the external interface on the subnet 10.1.7.0/24.

The FW devices egresses the traffic to the BIG-IP device on the subnet 10.1.3.0/24 to the "floating" IP address (moved during failover via API calls).

The BIG-IP receives the traffic from the FW on its external interface (direct communication from the FW ENI to the BIG-IP ENI) and forwards the traffic to the 10.1.7.0/24 subnet that has a route that forwards the traffic to the Workload VPC via Transit Gateway.

The return traffic from the Workload VPC goes back to the 10.1.5.0/24 subnet of the Inspection VPC and forwarded to the internal interface of the BIG-IP on 10.1.7.0/24.

Since the return traffic originates from the same interface that the BIG-IP sent the traffic to the Workload VPC it makes use of its connection table to return the traffic to the Firewall device that originally sent the traffic.  This is accomplished by making use of the Auto Lasthop feature of the BIG-IP.  This is possible because the BIG-IP and Firewall devices are located on the same subnet.

## Further Work

Currently this deploys a BIG-IP pair in a single AZ.  For a production deployment you would want to deploy an additional pair of devices in a separate AZ and allow Transit Gateway to distribute traffic from each AZ to the devices.  Failover has also not been fully configured to trigger an update of the Route Table entries (currently assumes that "bigip1" is the active device.

## Support
For support, please open a GitHub issue.  Note, the code in this repository is community supported and is not supported by F5 Networks.  For a complete list of supported projects please reference [SUPPORT.md](SUPPORT.md).

## Community Code of Conduct
Please refer to the [F5 DevCentral Community Code of Conduct](code_of_conduct.md).


## License
[Apache License 2.0](LICENSE)

## Copyright
Copyright 2014-2021 F5 Networks Inc.


### F5 Networks Contributor License Agreement

Before you start contributing to any project sponsored by F5 Networks, Inc. (F5) on GitHub, you will need to sign a Contributor License Agreement (CLA).

If you are signing as an individual, we recommend that you talk to your employer (if applicable) before signing the CLA since some employment agreements may have restrictions on your contributions to other projects.
Otherwise by submitting a CLA you represent that you are legally entitled to grant the licenses recited therein.

If your employer has rights to intellectual property that you create, such as your contributions, you represent that you have received permission to make contributions on behalf of that employer, that your employer has waived such rights for your contributions, or that your employer has executed a separate CLA with F5.

If you are signing on behalf of a company, you represent that you are legally entitled to grant the license recited therein.
You represent further that each employee of the entity that submits contributions is authorized to submit such contributions on behalf of the entity pursuant to the CLA.