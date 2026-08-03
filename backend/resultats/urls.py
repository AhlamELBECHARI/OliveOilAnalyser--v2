from rest_framework.routers import DefaultRouter

from .views import ResultatViewSet

router = DefaultRouter()
router.register("resultats", ResultatViewSet, basename="resultat")

urlpatterns = router.urls
