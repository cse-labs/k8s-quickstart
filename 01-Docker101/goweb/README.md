# go-web-aks

go-web-aks is a simple web server written in Go with some optimizations for deploying to AKS

Set the MY_NODE_NAME and MY_POD_NAME in the yaml file as follows:

```
spec:
  selector:
  template:
    spec:
      containers:
      - name: go-web-aks
        image: bartr/go-web-aks
        resources:
          requests:
            cpu: 200m
            memory: 128Mi
          limits:
            cpu: 400m
            memory: 256Mi
        ports:
        - containerPort: 80
        env:
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
                fieldPath: spec.nodeName
        - name: MY_POD_NAME
          valueFrom:
            fieldRef:
                fieldPath: metadata.name
```

Full yaml is available at <https://github.com/4-co/aks-quickstart/tree/master/app-gw>
