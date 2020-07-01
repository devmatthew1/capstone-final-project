pipeline{
    agent any
    stages{
        stage('Lint HTML Test'){
            steps {
                sh '''
					tidy -q -e *.html
					echo "Linting Test Done"
				'''
            }
        }
        stage('Build Image') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'DockerID', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker build -t surelay/capstone-final-project .
					'''
				}
			}
		}
        stage('Push Image') {
			steps {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'DockerID', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]){
					sh '''
						docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
						docker push surelay/capstone-final-project
					'''
				}
			}
		}

		stage('Kubernetes cluster creation') {
			steps {
				withAWS(region:'us-west-2', credentials:'surelay') {
					sh '''
						eksctl create cluster \
						--name capstone-project \
						--version 1.13 \
						--nodegroup-name standard-workers \
						--node-type t2.small \
						--nodes 2 \
						--nodes-min 1 \
						--nodes-max 3 \
						--node-ami auto \
						--region us-west-2 \
						--zones us-west-2a \
						--zones us-west-2b \
						--zones us-west-2c \
					'''
				}
			}
		}

		stage('Create conf file cluster') {
			steps {
				withAWS(region:'us-west-2', credentials:'surelay') {
					sh '''
						aws eks --region us-west-2 update-kubeconfig --name capstone-final-project
					'''
				}
			}
		}

		stage('Set current kubectl context') {
			steps {
				withAWS(region:'us-west-2', credentials:'surelay') {
					sh '''
						kubectl config use-context arn:aws:eks:us-west-2:526537859857:cluster/capstone-final-project
					'''
				}
			}
		}

		stage('Deploy blue container') {
			steps {
				withAWS(region:'us-west-2', credentials:'surelay') {
					sh '''
						kubectl apply -f ./blue-controller.yml
					'''
				}
			}
		}

		stage('Deploy green container') {
			steps {
				withAWS(region:'us-west-2', credentials:'surelay') {
					sh '''
						kubectl apply -f ./green-controller.yml
					'''
				}
			}
		}

		stage('Create the service in the cluster and redirect to blue') {
			steps {
				withAWS(region:'us-west-2', credentials:'surelay') {
					sh '''
						kubectl apply -f ./blue-service.yml
					'''
				}
			}
		}

		stage('Wait user approve') {
            steps {
                input "Redirect traffic to green?"
            }
        }

		stage('Create the service in the cluster and redirect to green') {
			steps {
				withAWS(region:'us-west-2', credentials:'surelay') {
					sh '''
						kubectl apply -f ./green-service.yml
					'''
				}
			}
		}

		stage('Details of Deployment') {
			steps {
				withAWS(region:'us-west-2', credentials:'surelay') {
					sh '''
						kubectl get pods
					'''
				}
			}
		}

	}
}
