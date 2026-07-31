from rest_framework.routers import DefaultRouter

from .views import ModeleViewSet

router = DefaultRouter()
router.register("modeles", ModeleViewSet, basename="modele")

urlpatterns = router.urls
