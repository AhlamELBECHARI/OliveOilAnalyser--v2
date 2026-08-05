from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("resultats", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="resultat",
            name="duree_analyse_secondes",
            field=models.PositiveIntegerField(null=True, blank=True),
        ),
    ]
