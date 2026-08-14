from django.urls import path

from . import views

urlpatterns = [
    path("admin/supervision/", views.SupervisionView.as_view(), name="admin-supervision"),
    path(
        "admin/journal-audit/",
        views.JournalAuditListView.as_view(),
        name="admin-journal-audit",
    ),
    path(
        "admin/donnees/statistiques/",
        views.StatistiquesOccupationView.as_view(),
        name="admin-donnees-statistiques",
    ),
    path(
        "admin/donnees/purge/apercu/",
        views.PurgeApercuView.as_view(),
        name="admin-donnees-purge-apercu",
    ),
    path("admin/donnees/purge/", views.PurgeExecuterView.as_view(), name="admin-donnees-purge"),
]
