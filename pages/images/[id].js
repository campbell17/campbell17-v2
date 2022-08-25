// import { getAllImageIds, getImageData } from '../../lib/images';
// import Image from 'next/image'
// import utilStyles from '../../styles/utils.module.scss';

// export async function getStaticProps({ params }) {
//   const imageData = await getImageData(params.id);
//   return {
//     props: {
//       imageData,
//     },
//   };
// }

// export async function getStaticPaths() {
//   const paths = getAllImageIds();
//   return {
//     paths,
//     fallback: false,
//   };
// }

// export default function Image({ imageData }) {
//   return (
//     <Image
//       priority
//       src={`/images/${imageData}.jpg`}
//       className={utilStyles.borderCircle}
//       height={144}
//       width={144}
//       alt={name}
//     />
//   );
// }