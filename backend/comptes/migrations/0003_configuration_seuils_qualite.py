from decimal import Decimal

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("comptes", "0002_remove_utilisateur_token_reset_expiration_and_more"),
    ]

    operations = [
        migrations.AddField(
            model_name="configuration",
            name="seuil_acidite_evoo",
            field=models.DecimalField(
                max_digits=6, decimal_places=3, default=Decimal("0.800")
            ),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="configuration",
            name="seuil_acidite_voo",
            field=models.DecimalField(
                max_digits=6, decimal_places=3, default=Decimal("2.000")
            ),
            preserve_default=False,
        ),
    ]
