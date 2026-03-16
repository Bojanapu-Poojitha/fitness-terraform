# Fitness app with terraform and Ansible .

- It is implemented with terraform(AWS Infrastructure) and Ansible(app deploying).


## Features : 

- Create `VPC's` for private network .

- Use `EC2` instances for frontend and backend .

- Use `RDS` service to store data 

- Create `SES` to send verification code ot emails.

- Use `S3` buckets for original and thumbnail image .

- Add `lambda` service to generate thumbnail image .

- Use `lambda.zip` file to resize image in thumbnail.

- Implement `security groups` for RDS and EC2 instances .


## Installation and Set up : 

- To clone the repo in your local machine , clone this repo in your local CLI : 

``` bash 

    git clone https://github.com/Bojanapu-Poojitha/fitness-terraform.git

```

- To run the terraform after cloning the repo : 

```bash

    terraform apply

```

- To destroy the services permanently in AWS too , the command is : 

```bash

    terraform destroy

```