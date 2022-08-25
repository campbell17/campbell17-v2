// import fs from 'fs';
// import path from 'path';

// const imagesDirectory = path.join(process.cwd(), 'public/images');

// export function getAllImageIds() {
//   const fileNames = fs.readdirSync(imagesDirectory);

//   // Returns an array that looks like this:
//   // [
//   //   {
//   //     params: {
//   //       id: 'profile'
//   //     }
//   //   },
//   //   {
//   //     params: {
//   //       id: 'tall-drawing-111120'
//   //     }
//   //   }
//   // ]
//   return fileNames.map((fileName) => {
//     return {
//       params: {
//         id: fileName.replace(/\.jpg$/, ''),
//       },
//     };
//   });
// }
// export async function getImageData(id) {
//   const imagePath = path.join(imagesDirectory, `${id}.jpg`);

//   // Combine the data with the id and contentHtml
//   return {
//     id,
//     ...imagePath.data,
//   };
// }