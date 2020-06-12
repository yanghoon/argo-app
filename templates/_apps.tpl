{{- define "apps.tpl" -}}
{{/*
# https://helm.sh/docs/chart_template_guide/functions_and_pipelines/
# https://github.com/Masterminds/sprig/blob/master/docs/dicts.md#merge-mustmerge
*/}}
{{- $v := .Values }}
{{- $g := .Values.global }}
{{- $t := .Values.template }}
{{- range $name, $app := .Values.apps }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ printf "%s-%s" $.Release.Name $name  }}
  labels:
    chart: {{ template "argo-app.chart" $ }}
    release: {{ $.Release.Name }}
{{- $m := index $t ($app.template | default $name) }}
{{- $m := merge dict (omit $app "template") $m }}
{{- $values := dict "values" $m.values "valueFiles" $m.valueFiles "root" $ }}
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
    {{- with (include "unpack" $m.parameters) }}
      parameters:
{{ . | trim | indent 6 }}
    {{- end }}
  destination:
    server: {{ $m.server | default $g.server }}
    namespace: {{ $m.namespace | default $g.namespace }}
---
{{- end }}
{{- end -}}