# Helm Charts Explained
Written by: Christine Tang

Objective:
* Understand what are Helm Charts
* Understand when to use them
* Make my own Helm Charts


What problem do they solve?
* You make a lot of yaml or configuration files when configuring deployment onto AWS Kubernetes for deployment.
* It's really easy to lose track fo which files are for deployment in which environment
* Undoing mistakes is hard

One command for deployment:
```code 
helm install myapp ./helm-chart --set replicas=3
```

The structure of most helm-chart folders:
[Claude, insert the tree structure here]


## Chart.yaml
* Contains the meta-data

## values.yaml
* Contains the list of variables and configuration files you can change.
* We have two deployment configurations, one for development and one for production.

## 