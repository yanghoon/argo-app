{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{/*
  https://godoc.org/text/template
  https://masterminds.github.io/sprig/
*/}}
{{- define "argo-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argo-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argo-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "unpack" -}}
{{- range $name, $value := . }}
- name: "{{ $name }}"
  value: "{{ $value }}"
{{- end }}
{{- end -}}

{{- define "valueFiles" -}}
{{- with (include "filterValueFiles" .valueFiles ) -}}
{{ . }}
{{- end -}}
{{- end -}}

{{- define "filterValueFiles" -}}
{{- range $file := . }}
  {{- if not (hasPrefix "values/" $file) -}}
- {{ $file }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "values" -}}
  {{- $root := .root -}}
  {{- $values := .values | default (include "mergeValueFiles" .) -}}
  {{- with $values -}}
{{ . }}
  {{- end -}}
{{- end -}}

{{- define "mergeValueFiles" -}}
{{- $root := .root -}}
{{- $_ := set $ "v" dict -}}
{{- range $f := .valueFiles -}}
  {{- if hasPrefix "values/" $f }}
    {{- with ($root.Files.Glob $f) -}}
{{- $_ := set $ "v" (merge (index . $f | toString | fromYaml) $.v) -}}
    {{- end -}}
  {{- end }}
{{- end -}}
{{- with .v -}}
{{ . | toYaml | trim }}
{{- end -}}
{{- end -}}