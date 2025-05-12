# Verifica qual comando de Compose está disponível
ifeq (, $(shell which docker-compose 2>/dev/null))
  ifeq (, $(shell which podman-compose 2>/dev/null))
    ifeq (, $(shell which docker 2>/dev/null) && $(shell docker version --format '{{.Client.APIVersion}}' | grep -q "v2"))
      $(error "Nenhum comando docker-compose, podman-compose ou docker (V2) foi encontrado no sistema.")
    else
      COMPOSE_BASE = docker compose
    endif
  else
    COMPOSE_BASE = podman-compose
  endif
else
  COMPOSE_BASE = docker-compose
endif

COMPOSE_DEV = $(COMPOSE_BASE) -f docker-compose.yaml -f docker-compose.override.yaml
COMPOSE_PROD = $(COMPOSE_BASE) -f docker-compose.yaml

.PHONY: default dev stop submodule

## Sobe todos os serviços em modo prod
default:
	$(COMPOSE_PROD) up --build -d

## Sobe todos os serviços em modo dev
dev:
	$(COMPOSE_PROD) up --build

## Para e remove todos os containers
stop:
	$(COMPOSE_BASE) down

## Para um serviço específico: make stop-<serviço>
stop-%:
	$(COMPOSE_BASE) stop $*

## Para um serviço específico: make down-<serviço>
down-%:
	$(COMPOSE_BASE) down $*	

## Atualiza os submódulos
submodule:
	git submodule update --init --recursive --remote
