Infrastructure for a business-critical EKS microservice handling hotel
point deductions, built for the Cloud Engineer technical assessment
(Accor, AAPC Thailand).

## Deliverables

1. **Infrastructure as Code and Kubernetes manifests**: [`Code/terraform/`](Code/terraform/)
   (two Terraform root modules, `infrastructure` and `helm`, applied via
   [`Code/terraform/run.sh`](Code/terraform/run.sh)) and
   [`Code/kubernetes/sample-app/`](Code/kubernetes/sample-app/) (the
   application Helm chart).
2. **Architecture diagrams**: [`Diagram/`](Diagram/)
   - [`Architecture-HA.drawio`](Diagram/Architecture-HA.drawio) ([PDF](Diagram/Architecture-HA.drawio.pdf)) — single-region, high-availability view.
   - [`Architecture-HA-DR.drawio`](Diagram/Architecture-HA-DR.drawio) ([PDF](Diagram/Architecture-HA-DR.drawio.pdf)) — multi-region, high-availability and disaster-recovery view.
   - [`Network Diagram.drawio`](Diagram/Network%20Diagram.drawio) ([PDF](Diagram/Network%20Diagram.drawio.pdf)) — AZ/subnet-level network layout.
3. **Design document**: [`Report/Design Document.pdf`](Report/Design%20Document.pdf).

## Quick start

```bash
cd Code/terraform
./run.sh create   # applies the infrastructure module, then the helm module
./run.sh destroy  # tears down the infrastructure module
```
