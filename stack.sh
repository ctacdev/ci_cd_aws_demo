#!/bin/bash

STACK_NAME='CiCdDemoCloudFormationStack'

rm -f initialJenkinsAdminPassword

function create_stack {

    echo "creating stack ..."
    local arn=$(aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name $STACK_NAME --template-body file://stack.yml)
    echo $arn > stack_arn
}

function open_jenkins {
    local instance_ip=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | awk 'END{print $NF}')
    echo "opening http://$instance_ip:8080/login ..."
    open http://$instance_ip:8080/login > /dev/null 2>&1
}

function wait_for_stack {

    echo "waiting for stack creation to complete ..."
    aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
    echo "stack created - $(cat stack_arn)"

    local instance_ip=$(aws cloudformation describe-stacks --stack-name $STACK_NAME | awk 'END{print $NF}')
    echo "waiting for jenkins to start on $instance_ip ..."
    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $instance_ip:8080/login)" != "200" ]]; do
        sleep 5;
    done

    echo "saving jenkins initial admin password"
    ssh -t ec2-user@$instance_ip -i CiCdDemoKey.pem -o 'StrictHostKeyChecking=no' 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword' 2> /dev/null > initialJenkinsAdminPassword

    open_jenkins
}

function delete_stack {
    aws cloudformation delete-stack --stack-name $STACK_NAME
    aws ecr delete-repository --force --repository-name ci-cd-demo > /dev/null 2>&1
}

function validate_template {
    aws cloudformation validate-template --template-body file://stack.yml
}

function update_stack {

    echo "updating stack ..."
    local arn=$(aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_NAME --template-body file://stack.yml)
    echo $arn > stack_arn
}

function show_usage {
  echo 'TODO: usage'
}

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case $PARAM in
    -h | --help)
      show_usage
      exit
      ;;
    --create-stack)
      create_stack
      ;;
    --wait-for-stack)
      wait_for_stack
      ;;
    --update-stack)
      update_stack
      ;;
    --delete-stack)
      delete_stack
      ;;
    --validate-template)
      validate_template
      ;;
    --open-jenkins)
      open_jenkins
      ;;
    *)
      echo "ERROR: unknown parameter \"$PARAM\""
      show_usage
      exit 1
      ;;
  esac
  shift
done
