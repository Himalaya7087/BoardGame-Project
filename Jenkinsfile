pipeline{
    agent any
    
    environment{
        SCANNER_HOME = tool 'sonar-scanner'
        PATH = "/usr/local/bin:${env.PATH}"
        ACCOUNT_ID = "533267043749"
        ECR_REPO="himalaya7087"
        IMAGE_TAG="boardgame-app-${env.BUILD_NUMBER}"
    }
    
    tools{
        jdk "openjdk11"
        maven "maven398"
    }
    
    stages{
        
        stage("Clean Workspace"){
            steps{
                cleanWs()
            }
        }
        
        stage("Code Checkout"){
            steps{
                git credentialsId: '9e561c85-406b-4f5a-ba0d-fe4e74733729', url: 'https://github.com/Himalaya7087/BoardGame-Project', branch: 'main'
            }
        }
        
        stage("Compile the code"){
            steps{
                sh "mvn clean package"
            }
        }
        
        // stage("Run Test Cases"){
        //     steps{
        //         sh "mvn test"
        //     }
        // }
        
        stage("Sonarqube Analysis"){
            tools{
                jdk "openjdk17"
            }
            steps{
                withSonarQubeEnv('sonarqube-scanner') {
                    sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=boardgame -Dsonar.java.binaries=. -Dsonar.projectKey=boardgame "
                }
            }
        }
        
        stage("Source Code Scan"){
            steps{
                sh"""
                  export PATH=/usr/local/bin:$PATH
                  trivy fs --format table -o trivy-scan-report.html .
                """
            }
        }
        
        // stage("Build Artifact"){
        //     steps{
        //         sh "mvn package"
        //     }
        // }
        
        // stage("Publish Artifact"){
        //     steps{
        //         withMaven(globalMavenSettingsConfig: 'nexus-repo', jdk: 'openjdk17', maven: 'maven398', mavenSettingsConfig: '', traceability: true) {
        //             sh "mvn deploy"
        //         }
        //     }
        // }
        
        stage("Docker-Image"){
            steps{
                sh """
                    docker image prune -a --force
                    docker build -t himalaya7087 .
                    docker tag himalaya7087:latest 533267043749.dkr.ecr.ap-south-1.amazonaws.com/himalaya7087:${env.IMAGE_TAG}
                """
            }
        }
        
        stage("Push Docker Image to ECR"){
            steps{
                sh """
                    aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 533267043749.dkr.ecr.ap-south-1.amazonaws.com
                    docker push 533267043749.dkr.ecr.ap-south-1.amazonaws.com/himalaya7087:${env.IMAGE_TAG}
                """
            }
        }
        //  stage('Deploy to EKS') {
        //     steps {
        //         dir("deployment"){
        //             sh """
        //                aws eks update-kubeconfig --name mbp-eks
        //                 envsubst < ./deployment.yaml.tmpl > deployment.yaml
        //                 envsubst < ./service.yaml.tmpl > service.yaml
        //                 envsubst < ./ingress.yaml.tmpl > ingress.yaml
                        
        //                 kubectl apply -f deployment.yaml
        //                 kubectl apply -f service.yaml
        //                 kubectl apply -f ingress.yaml
        //             """
        //         }
        //     }
        // }

        stage("Update New Image in Git Repo"){
            steps{
                build(job: "Deploy-Boardgame-ArgoCD", parameters: [
                    string(name: 'NEW_IMAGE_TAG', value: "${env.IMAGE_TAG}")
                ])
            }
        }
        
    }
}