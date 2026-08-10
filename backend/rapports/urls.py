from django.urls import path

from .views import TelechargerRapportView

urlpatterns = [
    path("rapports/<uuid:pk>/telecharger/", TelechargerRapportView.as_view(), name="rapport-telecharger"),
]
