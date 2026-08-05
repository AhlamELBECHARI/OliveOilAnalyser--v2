from django.urls import path

from .views import StatistiquesDashboardView

urlpatterns = [
    path(
        "dashboard/statistiques/",
        StatistiquesDashboardView.as_view(),
        name="dashboard-statistiques",
    ),
]
