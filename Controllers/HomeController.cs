using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using DotNetCoreSqlDb.Models;

namespace DotNetCoreSqlDb.Controllers
{
    public class HomeController : Controller
    {
        public int Action {get; set;}
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Privacy()
        {
            IActionResult result = View("PrivcayView");
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
