using System;
using System.IO;
using Newtonsoft.Json;

namespace LinkOpener.Models
{
    public class AppSettings
    {
        public string LastBrowser { get; set; } = "Chrome";
        public bool PrivateMode { get; set; } = false;
        public bool RememberPreferences { get; set; } = false;

        private static string SettingsPath => Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
            "LinkOpener", "settings.json");

        public static AppSettings Load()
        {
            try
            {
                if (File.Exists(SettingsPath))
                {
                    var json = File.ReadAllText(SettingsPath);
                    return JsonConvert.DeserializeObject<AppSettings>(json) ?? new AppSettings();
                }
            }
            catch { }
            return new AppSettings();
        }

        public void Save()
        {
            try
            {
                if (RememberPreferences)
                {
                    var directory = Path.GetDirectoryName(SettingsPath);
                    if (directory != null && !Directory.Exists(directory))
                    {
                        Directory.CreateDirectory(directory);
                    }
                    var json = JsonConvert.SerializeObject(this, Formatting.Indented);
                    File.WriteAllText(SettingsPath, json);
                }
            }
            catch { }
        }
    }
}