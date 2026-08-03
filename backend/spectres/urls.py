from rest_framework.routers import DefaultRouter

from .views import SpectreViewSet

router = DefaultRouter()
router.register("spectres", SpectreViewSet, basename="spectre")

urlpatterns = router.urls
