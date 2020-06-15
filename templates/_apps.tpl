{{- define "apps.tpl" -}}
{{/*
# https://helm.sh/docs/chart_template_guide/functions_and_pipelines/
# https://github.com/Masterminds/sprig/blob/master/docs/dicts.md#merge-mustmerge
*/}}
{{- $v := .Values }}
{{- $g := .Values.global }}
{{- $t := .Values.template }}
{{- range $name, $app := .Values.apps }}
{{- if ne (toString $app.enabled) "false" }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ printf "%s-%s" $.Release.Name $name  }}
  labels:
    chart: {{ template "argo-app.chart" $ }}
    release: {{ $.Release.Name }}
{{- $helm := pick $app "values" "valueFiles" "parameters" }}
{{- $source := merge (pick $app "repoURL" "chart" "targetRevision") (dict "helm" $helm) }}
{{- $destination := pick $app "server" "namespace" }}
{{- $m := index $t ($app.template | default $name) }}
{{- $m := merge dict (dict "source" $source "destination" $destination) $m }}
{{- $values := dict "values" $m.source.helm.values "valueFiles" $m.source.helm.valueFiles "root" $ }}
spec:
  project: {{ $m.project | default $g.project }}
  source:
{{ toYaml (pick $m.source "repoURL" "chart" "targetRevision") | trim | indent 4 }}
    helm:
    {{- with (include "valueFiles" $values) }}
      valueFiles:
{{ . | indent 6 }}
    {{- end }}
    {{- with (include "values" $values) }}
      values: |-
{{ . | indent 8 }}
    {{- end }}
    {{- with (include "unpack" $m.source.helm.parameters) }}
      parameters:
{{ . | trim | indent 6 }}
    {{- end }}
  destination:
    server: {{ $m.destination.server | default $g.server }}
    namespace: {{ $m.destination.namespace | default $g.namespace }}
---
{{- end }}
{{- end }}
{{- end -}}