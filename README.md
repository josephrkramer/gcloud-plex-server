# gcloud-plex-server
Scripts to automate creation of a Plex Server on Google Compute Engine

## GitHub Actions for Server Management

This repository now uses GitHub Actions to automate the startup and shutdown of the Plex server on Google Cloud.

### Workflows

*   **Plex Startup (`.github/workflows/startup.yml`):** This workflow automates the process of:
    1.  Finding the most recent Google Cloud snapshot.
    2.  Creating a new persistent disk from this snapshot.
    3.  Creating a new Compute Engine VM instance using a predefined template and the new disk.
*   **Plex Shutdown (`.github/workflows/shutdown.yml`):** This workflow automates the process of:
    1.  Stopping the most recent Compute Engine VM instance.
    2.  Creating a new snapshot from the instance's boot disk.
    3.  Deleting the oldest snapshot if more than two snapshots exist.
    4.  Deleting the Compute Engine VM instance.

### Setup

To use these workflows, you need to configure the following:

1.  **Google Cloud Service Account:**
    *   Create a service account in your Google Cloud project.
    *   Grant this service account the following roles (or a custom role with equivalent permissions):
        *   `Compute Instance Admin (v1)` (roles/compute.instanceAdmin.v1) - for managing VM instances.
        *   `Compute Storage Admin` (roles/compute.storageAdmin) - for managing disks and snapshots.
        *   `Service Account User` (roles/iam.serviceAccountUser) - if the VM instance runs as a service account (check your instance template).
    *   Download the JSON key file for this service account.

2.  **GitHub Secrets:**
    *   In your GitHub repository, go to `Settings` > `Secrets and variables` > `Actions`.
    *   Create a new repository secret named `GCP_SA_KEY`. Paste the entire content of the JSON service account key file into this secret.
    *   (Optional but Recommended) Create another secret named `GCP_PROJECT_ID` and set its value to your Google Cloud Project ID. If you don't set this, the workflows will use the project ID hardcoded in the workflow files (`basic-lock-251300`), but using a secret is more flexible and secure. The workflows have been written to use the `GCP_PROJECT_ID` secret if available.

### Triggering the Workflows

Both workflows are configured for manual triggering:

1.  Go to the "Actions" tab in your GitHub repository.
2.  In the left sidebar, you will see "Plex Startup" and "Plex Shutdown".
3.  Select the workflow you want to run.
4.  Click the "Run workflow" button. You can typically leave the branch as `main` (or your default branch).

---

### Rclone
Install and configure rclone for filesystem access

```
sudo apt-get install rclone
rclone config
```

### Remote desktop

Remote desktop auto-install instructions:
- https://cloud.google.com/architecture/chrome-desktop-remote-on-compute-engine
- Monitor gcloud-startup-script.sh install progress
```
sudo journalctl -o cat -f _SYSTEMD_UNIT=google-startup-scripts.service
```
- Set a password
```
sudo passwd $(whoami)
```
- Add user to sudoers
```
sudo adduser $(whoami) sudo
```
- https://remotedesktop.google.com/headless

Configure plex from remote desktop machine:
- http://127.0.0.1:32400/web

### Reference
Install guides to use as templates for later automation:
- https://www.linuxbabe.com/ubuntu/install-plex-media-server-ubuntu-18-04
- https://linuxize.com/post/how-to-install-plex-media-server-on-debian-9/
- https://www.cyberciti.biz/faq/how-to-set-up-automatic-updates-for-ubuntu-linux-18-04/

Backup instructions for later automation:
- https://support.plex.tv/articles/201539237-backing-up-plex-media-server-data/

### Archive
From https://github.com/plexdrive/plexdrive -- OBSOLETE
- Link to latest plexdrive asset https://github.com/plexdrive/plexdrive/releases/latest/download/plexdrive-linux-amd64