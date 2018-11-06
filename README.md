## Terraform ElasticBeanstalk with single docker container stack for GETH and Pocket 

This terraform project creates the following resources in `us-east-1` in your AWS account:


- 1 VPC [vpc_setup.tf](vpc_setup.tf)
- 6 subnets (3 private and 3 public) [vpc_setup.tf](vpc_setup.tf)
- 1 Internet Gateway and 1 NAT gateway for providing internet access to private instances ([vpc_setup.tf](vpc_setup.tf) and [nat.tf](nat.tf))
- 3 Route tables [vpc_setup.tf](vpc_setup.tf)

- 1 Unique keypair for the instances on the 2 ELB and bastion
- 2 Security groups for the instances in each of the ELBs
- 2 ELB applications [elasticbeanstalk.tf](elasticbeanstalk.tf)
- 2 ELB environments (Single container Docker) [elasticbeanstalk.tf](elasticbeanstalk.tf)
  - 1 Internal LoadBalancer and t3.large instances for GETH nodes 
  - 1 Public LoadBalancer and t3.small instances for Pocket nodes
  - All ELB instances are behind private subnets
  - Scaling groups with network rules
  - Enhanced Monitoring
  - Notifications to an specified email
- (Optional) Provides a bastion instance for the `main-public-1` subnet (in case you want to access the instances ) [elasticbeanstalk.tf](elasticbeanstalk.tf) 


### Usage

####  Installation and configuration 

First you need to [install terraform](https://www.terraform.io/intro/getting-started/install.html) and the [awscli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) correctly configured with a default profile using the following variables in your environment:

```
AWS_ACCESS_KEY = "YOUR ACCESS KEY"
AWS_SECRET_KEY = "YOUR SECRET KEY"
```

Then inside the project folder:

```
  $ terraform init 
```

Finally, you need to get the public key of an existing ssh keypair from aws to use it as the keypair of the instances we are creating


For obtainning public ssh keys for the instances you should use:

``` $ sudo ssh-keygen -y -f private_key.pem ```

And copy the result inside the `default` value in the variable `public_keypair` on `vars.tf`


### Execute


Then execute the plan using terraform:

```
terraform plan   # to show the plan
terraform apply  # to apply the changes
```

In both commands, terraform will ask:

```
  var.create_bastion
    Enter a value: yes

  var.environment
    Enter a value: staging 

  var.notify_email
    Enter a value: youremail@email.com

```


#### Deploying

After we run our terraform script and checked that everything is running and the resources are created as expected. We will proceed to deploy the geth-mainnet and geth-testnet containers.


#### Deploying geth-mainnet


> cd geth-mainnet


Inside the geth-mainnet folder you neeed to edit the file `.elasticbeanstalk/config.yml` with the parameters that matchs the configuration that you already created for your ELB.

After you edited everything as expected you should proceed with the following commands to deploy the docker container properly:


> make deploy ENV=geth-mainnet-node-staging

Just replace `staging` with the environment that you deployed using terraform before

The make command uses the Makefile for zipping the content of the folder `geth-mainnet` and deploying it in the ELB interface automatically.

For more information about configuration in Elasticbeanstalk. Please check this (link)[https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environment-configuration-methods-before.html]

Once this is done, this will deploy to ELB and will create a docker container with geth configured for mainnet purposes. Also it will run the commands described in `.ebextensions/` in order to 
modify the storage of docker to overlay2 for using all the disk space in  the docker container and restart the docker daemon. For more information about the functionality of the ELB and other configurations please check (this)[https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/ebextensions.html]


#### Deploying geth-testnet


FOr deploying testnet is the same procedure as the step before

> cd geth-testnet


Edit the configuration file that matchs your setup inside `.elasticbeanstalk/config.yml` and then proceed with:


> make deploy ENV=geth-testnet-node-staging


Replacing `staging` with the environment that you deployed using terraform before. 


Please check the links in the `Deploying geth-mainnet` step for more info



#### Customizing 
  
For customize you can directly edit vars.tf and the related terraform files mentioned in the list of resources at the beginning of this document.

In case you want to create those resources in another region, you should change the region in [vars.tf](vars.tf) and change the AMI image with an AMI for that specific region for the [bastion.tf](bastion.tf)  


#### Scaling triggers

We configured the scaling group policies with the network perfomance limits of the instances in mind. Please [check](https://cloudonaut.io/ec2-network-performance-cheat-sheet/) for more info


#### References

- Forked from (wardviaene)(https://github.com/wardviaene/terraform-demo)
- Terraform [aws_elastic_beanstalk_environment](https://www.terraform.io/docs/providers/aws/r/elastic_beanstalk_environment.html) options
