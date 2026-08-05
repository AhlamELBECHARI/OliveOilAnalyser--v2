"""
Sérialiseurs génériques utilisés uniquement pour documenter le schéma
OpenAPI (drf-spectacular) des vues qui ne s'appuient pas sur un
ModelSerializer — jamais pour de la validation d'entrée.
"""

from rest_framework import serializers


class ErreurSerializer(serializers.Serializer):
    """Forme de toute réponse d'erreur JSON, produite par
    core.exceptions.gestionnaire_exceptions : un code stable et non traduit,
    plus un détail lisible destiné aux logs/au débogage."""

    code = serializers.CharField()
    detail = serializers.CharField()


class MessageSerializer(serializers.Serializer):
    """Réponse de succès ne portant qu'un message informatif."""

    detail = serializers.CharField()
