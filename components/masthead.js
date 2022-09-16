export default function Masthead(props) {
  return (
    <section>
      <h1 className="title">{props.title}</h1>
      <p>{props.subtitle}</p>
      {props.children}
    </section>
  )
}