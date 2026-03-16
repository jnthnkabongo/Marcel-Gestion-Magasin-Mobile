# Page de Connexion Flutter - Marcel Gestion

## Description

J'ai créé une page de connexion Flutter qui reproduit fidèlement le design et les fonctionnalités de la page web de votre application Marcel Gestion.

## Fichiers créés/modifiés

### 1. `/lib/pages/login.dart`
Page de connexion complète avec :
- **Design responsive** (desktop/mobile)
- **Animation de fond** avec bulles flottantes
- **Formulaire de connexion** avec validation
- **Formulaire d'inscription** avec validation
- **Tabs animées** pour basculer entre connexion/inscription
- **Icônes Material** (remplacé FontAwesome)
- **SnackBar** pour les messages d'erreur/succès

### 2. `/lib/main.dart`
Fichier principal mis à jour pour :
- Importer la page de connexion
- Utiliser `LoginPage` comme page d'accueil
- Thème violet cohérent avec l'application web

### 3. `/pubspec.yaml`
Ajout de la dépendance (non utilisée finalement) :
```yaml
dependencies:
  font_awesome_flutter: ^10.0.0  # Pas nécessaire finalement
```

## Fonctionnalités

### 🎨 Design
- **Gradient de fond** identique à la version web (#667EEA → #764BA2)
- **Bulles animées** en arrière-plan
- **Effet glassmorphism** sur le formulaire
- **Responsive design** (layout différent pour desktop/mobile)

### 📝 Formulaires
- **Connexion** : Email + Mot de passe + "Se souvenir" + "Mot de passe oublié"
- **Inscription** : Nom + Email + Mot de passe + Confirmation
- **Validation** en temps réel des champs
- **Toggle visibilité** du mot de passe

### ✨ Animations
- **Transition fluide** entre les tabs
- **Animation d'apparition** du formulaire
- **Hover effects** sur les boutons
- **SnackBar animées** pour les feedbacks

### 🎯 Validation
- **Champs obligatoires** vérifiés
- **Format email** valide
- **Longueur mot de passe** minimum 6 caractères
- **Correspondance** des mots de passe (inscription)

## Pour lancer l'application

```bash
cd marcelgestion
flutter run
```

## Prochaines étapes suggérées

1. **Intégration API** : Connecter les formulaires à votre backend Laravel
2. **Navigation** : Ajouter la navigation vers le tableau de bord après connexion
3. **Stockage** : Gérer le token d'authentification
4. **Tests** : Tester sur différents appareils et tailles d'écran

## Structure des fichiers

```
lib/
├── main.dart          # Point d'entrée
└── pages/
    └── login.dart      # Page de connexion
```

La page est maintenant prête à être utilisée et reproduit fidèlement l'expérience de votre application web !
