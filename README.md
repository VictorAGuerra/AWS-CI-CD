# CI/CD Pipeline com AWS CodePipeline, CodeBuild, ECR e EKS  
Projeto desenvolvido para a disciplina de Cloud, implementando um pipeline de CI/CD totalmente provisionado com Terraform, integrado ao GitHub e preparado para deploy automático em um cluster EKS.

---

## Objetivo
Implementar um pipeline de CI/CD utilizando serviços AWS para:

- Criar e versionar imagens Docker automaticamente.
- Publicar novas versões no Amazon ECR.
- Atualizar o deployment Kubernetes no EKS via CodeBuild.
- Provisionar toda a infraestrutura com **Terraform**, conforme exigido na atividade.

---

## Arquitetura da Solução

A solução utiliza:

- **GitHub** como origem do código.
- **AWS CodePipeline** para orquestração do fluxo CI/CD.
- **AWS CodeBuild (Build)** para:
  - build da imagem
  - criação de tag
  - push da imagem para o ECR

- **AWS CodeBuild (Deploy)** para:
  - ler a nova tag
  - atualizar o `deployment.yaml`
  - aplicar o novo deployment no cluster via `kubectl`

- **AWS ECR** para armazenar imagens Docker versionadas.
- **AWS S3** como artifact store do pipeline.

---

4. Provisionamento via Terraform

O Terraform cria automaticamente:

### Repositório ECR
Usado para armazenar as imagens geradas no CodeBuild.

### Bucket S3
Configurado como artifact store do CodePipeline.

### Projetos CodeBuild
- **Build Project** → faz build da imagem + push para o ECR  
- **Deploy Project** → executa `kubectl apply -f deployment.yaml`

### Pipeline CodePipeline
Com três etapas:

1. **Source** (GitHub)
2. **Build** (Build Project)
3. **Deploy** (Deploy Project)

Outputs do Terraform após `apply`:

```
ecr_repo_url = "<URI do repositório ECR>"
pipeline_bucket = "<bucket gerado dinamicamente>"
pipeline_name = "app-pipeline"
```


---

## Execução da Pipeline

Após o provisionamento:

1. Qualquer `git push` para o branch `main` dispara o pipeline.
2. O CodeBuild faz build da imagem e envia para o ECR.
3. A segunda etapa do CodeBuild atualiza o arquivo `deployment.yaml`
   substituindo a tag por `IMAGE_TAG`.
4. O `kubectl` aplica o novo deployment no EKS (quando o cluster está disponível).

---

## Conclusão

A atividade foi concluída atendendo a todos os requisitos implementáveis no ambiente disponível:

- Provisionamento 100% via Terraform  
- Criação dos serviços AWS necessários  
- Pipeline completa configurada  
- Automação de build e deploy implementada 

---

## Grupo
Dupla responsável pelo desenvolvimento do projeto.
- Victor A. Guerra (vag@cesar.school)
- Walter Barreto (wasbf@cesar.school) 
---

