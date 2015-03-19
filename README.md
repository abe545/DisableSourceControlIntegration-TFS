### DisableSourceControlIntegration-TFS
NuGet package to prevent NuGet packages from being added to TFS.

Adds a NuGet.config file, and .tfignore file so that your packages won't be checked into source control. Even though that means this package will be added by default, at least it includes no binaries.
