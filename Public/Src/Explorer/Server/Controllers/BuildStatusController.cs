﻿// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;

namespace BuildXL.Explorer.Server.Controllers
{
    [Route("[controller]")]
    [ApiController]
    public class BuildStatusController : LoadController
    {
        public BuildStatusController(IMemoryCache memoryCache, IHostingEnvironment env)
            : base(memoryCache, env)
        {
        }

        /// GET buildStatus
        [HttpGet]
        public PhysicalFileResult Get(string xlg, string buildId)
        {
            var filePath = GetXlgPath(buildId, xlg);

            if (!string.IsNullOrEmpty(filePath))
            {
                string fullPath = filePath + "\\BuildXL.status.csv";
                if (System.IO.File.Exists(fullPath))
                {
                    return PhysicalFile(fullPath, "text/csv");
                }
            }      
            return null;
        }
    }
}
