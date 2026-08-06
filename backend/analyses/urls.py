from django.urls import path

from .views import ExportAnalysesView, HistoriqueAnalysesView, StatistiquesRapidesView

urlpatterns = [
    path("analyses/historique/", HistoriqueAnalysesView.as_view(), name="analyses-historique"),
    path(
        "analyses/statistiques-rapides/",
        StatistiquesRapidesView.as_view(),
        name="analyses-statistiques-rapides",
    ),
    path("analyses/export/", ExportAnalysesView.as_view(), name="analyses-export"),
]
