// PocketBase Hooks
// Documentation: https://pocketbase.io/docs/js-overview/

// Example: Validate project data before creating
// onRecordBeforeCreateRequest((e) => {
//   const data = e.record;
//
//   // Custom validation
//   if (!data.get("baseUrl").startsWith("https://")) {
//     throw new BadRequestError("baseUrl must start with https://");
//   }
//
//   // Transform data
//   data.set("projectId", data.get("projectId").toLowerCase());
// }, "projects");

// Example: Log when a project is created
// onRecordAfterCreateRequest((e) => {
//   console.log("New project created:", e.record.get("name"));
// }, "projects");

// Example: Prevent deletion of active projects
// onRecordBeforeDeleteRequest((e) => {
//   if (e.record.get("isActive")) {
//     throw new BadRequestError("Cannot delete active projects");
//   }
// }, "projects");

// Example: Custom endpoint to get only active projects
// routerAdd("GET", "/api/custom/active-projects", (c) => {
//   const records = $app.dao().findRecordsByExpr("projects", $dbx.exp("isActive = true"));
//   return c.json(200, records);
// });

// Example: Add CORS headers
// routerUse((next) => {
//   return (c) => {
//     c.response().header().set("Access-Control-Allow-Origin", "*");
//     c.response().header().set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
//     c.response().header().set("Access-Control-Allow-Headers", "Content-Type, Authorization");
//
//     if (c.request().method === "OPTIONS") {
//       return c.noContent(204);
//     }
//
//     return next(c);
//   };
// });

console.log("PocketBase hooks loaded successfully");
