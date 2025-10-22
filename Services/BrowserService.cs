using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using LinkOpener.Models;

namespace LinkOpener.Services
{
    public class BrowserService
    {
        public static Dictionary<string, string> GetBrowserPaths()
        {
            return new Dictionary<string, string>
            {
                { "Chrome", @"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" },
                { "Firefox", @"C:\Program Files\Mozilla Firefox\firefox.exe" },
                { "Edge", @"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" },
                { "Brave", @"C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" },
                { "Helium", Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), 
                    @"imput\Helium\Application\chrome.exe") }
            };
        }

        public static List<BrowserInfo> GetInstalledBrowsers()
        {
            var browsers = new List<BrowserInfo>();
            var paths = GetBrowserPaths();

            foreach (var browser in paths)
            {
                browsers.Add(new BrowserInfo
                {
                    Name = browser.Key,
                    ExecutablePath = browser.Value,
                    IsInstalled = File.Exists(browser.Value)
                });
            }

            return browsers;
        }

        public static async Task OpenLinks(string browserName, List<string> links, bool privateMode)
        {
            var browserPath = GetBrowserPaths()[browserName];
            
            if (!File.Exists(browserPath))
            {
                throw new FileNotFoundException($"Browser not found: {browserName}");
            }

            await Task.Run(() =>
            {
                if (browserName == "Firefox")
                {
                    if (privateMode)
                    {
                        foreach (var link in links)
                        {
                            Process.Start(browserPath, new[] { "-private-window", link });
                            Thread.Sleep(800);
                        }
                    }
                    else
                    {
                        var args = new List<string> { "-new-tab" };
                        foreach (var link in links)
                        {
                            args.Add("-url");
                            args.Add(link);
                        }
                        Process.Start(browserPath, args.ToArray());
                    }
                }
                else
                {
                    var args = new List<string>();
                    
                    if (privateMode)
                    {
                        args.Add(browserName == "Edge" ? "-inprivate" : "--incognito");
                    }
                    
                    args.AddRange(links);
                    Process.Start(browserPath, args.ToArray());
                }
            });
        }
    }
}