export default function ContentBlock(props) {
  return (
    <div>
      <h2>{props.heading}</h2>
      <p>{props.content}</p>
      {props.children}
    </div>
  );
}