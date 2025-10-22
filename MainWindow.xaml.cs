using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using Microsoft.Win32;
using LinkOpener.Models;
using LinkOpener.Services;

namespace LinkOpener
{
    public partial class MainWindow : Window
    {
        private AppSettings _settings;
        private List<RadioButton> _browserRadioButtons = new();

        public MainWindow()
        {
            InitializeComponent();
            _settings = AppSettings.Load();
            InitializeBrowsers();
            LoadSettings();
        }

        private void InitializeBrowsers()
        {
            var browsers = BrowserService.GetInstalledBrowsers();

            foreach (var browser in browsers)
            {
                var radio = new RadioButton
                {
                    Content = browser.Name,
                    IsEnabled = browser.IsInstalled,
                    Margin = new Thickness(0, 0, 20, 0),
                    GroupName = "Browsers"
                };

                if (browser.Name == _settings.LastBrowser)
                {
                    radio.IsChecked = true;
                }

                _browserRadioButtons.Add(radio);
                BrowserPanel.Children.Add(radio);
            }

            if (_browserRadioButtons.All(r => r.IsChecked != true))
            {
                var firstEnabled = _browserRadioButtons.FirstOrDefault(r => r.IsEnabled);
                if (firstEnabled != null)
                {
                    firstEnabled.IsChecked = true;
                }
            }
        }

        private void LoadSettings()
        {
            PrivateModeCheckBox.IsChecked = _settings.PrivateMode;
            RememberCheckBox.IsChecked = _settings.RememberPreferences;
        }

        private void BrowseButton_Click(object sender, RoutedEventArgs e)
        {
            var dialog = new OpenFileDialog
            {
                Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*",
                Title = "Select links file"
            };

            if (dialog.ShowDialog() == true)
            {
                FilePathBox.Text = dialog.FileName;
                UpdatePreview(dialog.FileName);
                StatusBar.Text = "File loaded: " + dialog.FileName;
            }
        }

        private void Window_DragOver(object sender, DragEventArgs e)
        {
            e.Effects = e.Data.GetDataPresent(DataFormats.FileDrop) ? DragDropEffects.Copy : DragDropEffects.None;
            e.Handled = true;
        }

        private void Window_Drop(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {
                var files = (string[])e.Data.GetData(DataFormats.FileDrop);
                if (files != null && files.Length > 0 && files[0].EndsWith(".txt"))
                {
                    FilePathBox.Text = files[0];
                    UpdatePreview(files[0]);
                    StatusBar.Text = "File loaded: " + files[0];
                }
            }
        }

        private void UpdatePreview(string filePath)
        {
            try
            {
                var lines = File.ReadAllLines(filePath).Where(l => !string.IsNullOrWhiteSpace(l)).ToList();
                if (lines.Count > 0)
                {
                    var preview = string.Join(Environment.NewLine, lines.Take(5));
                    if (lines.Count > 5)
                    {
                        preview += $"{Environment.NewLine}{Environment.NewLine}... and {lines.Count - 5} more links";
                    }
                    PreviewBox.Text = preview;
                }
                else
                {
                    PreviewBox.Text = "No valid links found in file";
                }
            }
            catch (Exception ex)
            {
                PreviewBox.Text = $"Error reading file: {ex.Message}";
            }
        }

        private async void OpenButton_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrWhiteSpace(FilePathBox.Text) || !File.Exists(FilePathBox.Text))
            {
                MessageBox.Show("Please select a valid file!", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            var selectedBrowser = _browserRadioButtons.FirstOrDefault(r => r.IsChecked == true);
            if (selectedBrowser == null)
            {
                MessageBox.Show("Please select a browser!", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            var links = File.ReadAllLines(FilePathBox.Text).Where(l => !string.IsNullOrWhiteSpace(l)).ToList();
            if (links.Count == 0)
            {
                MessageBox.Show("No valid links found in the file!", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }

            _settings.LastBrowser = selectedBrowser.Content.ToString() ?? "Chrome";
            _settings.PrivateMode = PrivateModeCheckBox.IsChecked == true;
            _settings.RememberPreferences = RememberCheckBox.IsChecked == true;
            _settings.Save();

            try
            {
                OpenButton.IsEnabled = false;
                StatusBar.Text = $"Opening {links.Count} links in {_settings.LastBrowser}...";

                await BrowserService.OpenLinks(_settings.LastBrowser, links, _settings.PrivateMode);

                await Task.Delay(1500);
                StatusBar.Text = $"Done! Opened {links.Count} links successfully";
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error opening links: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                StatusBar.Text = "Error opening links";
            }
            finally
            {
                OpenButton.IsEnabled = true;
            }
        }
    }
}