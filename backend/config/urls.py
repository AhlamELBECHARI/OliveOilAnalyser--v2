from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("comptes.urls")),
    path("api/", include("echantillons.urls")),
    path("api/", include("spectres.urls")),
    path("api/", include("modeles.urls")),
    path("api/", include("resultats.urls")),
    path("api/", include("rapports.urls")),
    path("api/", include("alertes.urls")),
    path("api/", include("dashboard.urls")),
    path("api/", include("analyses.urls")),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path(
        "api/docs/",
        SpectacularSwaggerView.as_view(url_name="schema"),
        name="swagger-ui",
    ),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
